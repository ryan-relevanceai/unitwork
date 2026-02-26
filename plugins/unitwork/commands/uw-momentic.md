---
name: uw:momentic
description: "Run, create, debug, or upload Momentic E2E tests. Use for browser-based end-to-end testing with AI assertions, video recording, and persistent YAML test suites."
argument-hint: "<action> [args], e.g., 'run login.test.yaml' or 'create login flow test'"
---

# Momentic E2E Testing

Run, create, debug, or upload Momentic E2E tests.

## Initial Response

When invoked, determine the user's intent from the arguments: `$ARGUMENTS`

Supported actions:
- **run** `<test-file>` - Run an existing test
- **create** `<description>` - Create a new test YAML
- **debug** `<test-file>` - Debug a failing test by examining results
- **upload** `<output-dir>` - Upload results to Momentic Cloud
- **list** - List all available tests
- No arguments - show available tests and ask what to do

## Environment Setup

Always use these paths for Node/pnpm:
```bash
export PATH="$HOME/.nvm/versions/node/v22.18.0/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
```

Use full path for npx: `$HOME/.nvm/versions/node/v22.18.0/bin/npx`

## Finding the Momentic Config

Look for `momentic.config.yaml` in the current working directory or its parent directories. The config tells you:
- Where tests live (`include` patterns)
- Available environments (`environments` array with `name`, `baseUrl`, `envFile`)
- Whether video recording is enabled

## Momentic App Server

The Momentic desktop app server is required for MCP tool connectivity and can also be started by Claude instead of requiring the user to open the Momentic desktop app.

### Starting the Server

Before running tests or using MCP tools, ensure the Momentic app server is running:

```bash
# 1. Kill any existing Momentic processes first
pkill -9 -f 'momentic.*app' 2>/dev/null
pkill -9 -f 'momentic.*run' 2>/dev/null
pkill -9 -f 'chromium' 2>/dev/null

# 2. Find the directory containing momentic.config.yaml
MOMENTIC_DIR=$(find . -name "momentic.config.yaml" -maxdepth 3 -print -quit 2>/dev/null | xargs dirname 2>/dev/null)
if [ -z "$MOMENTIC_DIR" ]; then
  echo "No momentic.config.yaml found. Check your working directory."
  exit 1
fi

# 3. Start the server in the background
cd "$MOMENTIC_DIR" && \
nohup $HOME/.nvm/versions/node/v22.18.0/bin/npx momentic app -y \
  -c momentic.config.yaml \
  > /tmp/momentic-app.log 2>&1 &

# 4. Wait for it to be ready
sleep 5
grep -q 'Desktop server is running' /tmp/momentic-app.log && echo "Momentic server ready" || echo "Waiting..."
```

The server runs at `http://localhost:58888` by default.

### Stopping the Server

Always stop the server when done with testing:
```bash
pkill -9 -f 'momentic.*app' 2>/dev/null
pkill -9 -f 'chromium' 2>/dev/null
```

## Action: Run

1. Find the test file (glob for `*.test.yaml` if needed)
2. Check that `.env` file exists (required for login credentials). If not, create it with placeholders and ask the user to fill it in.
3. **CRITICAL: Kill any existing Momentic/Chromium processes before starting a new run.** Each `npx momentic run` spawns a headless Chromium instance. Overlapping runs or retries cause zombie processes that degrade the system (response times go from <1s to 5-13s).
```bash
pkill -9 -f 'momentic.*app' 2>/dev/null
pkill -9 -f 'momentic.*run' 2>/dev/null
pkill -9 -f 'chromium' 2>/dev/null
rm -rf /tmp/momentic-results
```
4. Start the Momentic app server (see "Momentic App Server" section above). The server must be running before `npx momentic run` is called.
5. Find the directory containing momentic.config.yaml and run the test from there:
```bash
MOMENTIC_DIR=$(find . -name "momentic.config.yaml" -maxdepth 3 -print -quit 2>/dev/null | xargs dirname 2>/dev/null)
cd "$MOMENTIC_DIR" && \
$HOME/.nvm/versions/node/v22.18.0/bin/npx momentic run <test-file> \
  --env local \
  --record-video \
  --output-dir /tmp/momentic-results \
  --retries 0 \
  --timeout-minutes 10 \
  -y
```
6. **After the test finishes (pass or fail), verify cleanup:**
```bash
ps aux | grep -E 'momentic|chromium' | grep -v grep
# Kill all Momentic processes including the app server:
pkill -9 -f 'momentic.*app' 2>/dev/null
pkill -9 -f 'momentic.*run' 2>/dev/null
pkill -9 -f 'chromium' 2>/dev/null
```
7. If the test passes, ask if the user wants to upload results to Momentic Cloud
8. If the test fails, automatically run the **debug** action on the results

## Action: Upload

Upload results to Momentic Cloud:
```bash
$HOME/.nvm/versions/node/v22.18.0/bin/npx momentic results upload <output-dir>
```

Return the Momentic Cloud URL to the user.

## Action: Create

When creating a new test:

1. Read existing tests in the project for patterns (glob for `*.test.yaml` and `*.module.yaml`)
2. Check if a login module already exists - reuse it if so
3. Generate the test YAML following these rules:

### Required Test Schema

```yaml
id: <uuid>  # MUST use "id", NOT "testId"
name: <test-name>
description: <what this test verifies>
advanced:
  viewportWidth: 1440
  viewportHeight: 900
  smartWaitingTimeoutMs: 30000
  browserType: chromium
retries: 0
envs:
  - dev
steps:
  # ... steps here
```

### Key Rules
- Every step needs a unique UUID for `id` and `command.id`
- Use `type: PRESET_ACTION` for all action steps
- Use AI_ASSERTION with generous timeouts (30-120s) for async operations
- Add WAIT steps (3-5s) between actions that trigger network requests
- Use `clearContent: true` when typing into inputs
- **Always set `retries: 0`** to prevent zombie Chromium processes during iterative development
- The Vibe Tool UI shows a summary view after AI generates code (name, SOP, Run button) - NOT raw code. Code is behind the "View code" toggle.
- `{{ baseUrl }}` is NOT a valid template variable. Momentic opens at the config's baseUrl automatically.
- Use `{{ env.VAR_NAME }}` for environment variables from `.env`

### Common Step Patterns

```yaml
# Set localStorage (e.g., point to local backend)
- id: <uuid>
  type: PRESET_ACTION
  command:
    id: <uuid>
    type: LOCAL_STORAGE
    key: api-url
    value: http://localhost:8001

# Login module
- type: MODULE
  moduleId: <module-id-from-module-yaml>

# Click by AI description
- id: <uuid>
  type: PRESET_ACTION
  command:
    id: <uuid>
    type: CLICK
    target:
      type: description
      elementDescriptor: The Submit button

# Type into input
- id: <uuid>
  type: PRESET_ACTION
  command:
    id: <uuid>
    type: TYPE
    clearContent: true
    pressEnter: false
    target:
      type: description
      elementDescriptor: The input field
    value: "some text"

# AI assertion
- id: <uuid>
  type: PRESET_ACTION
  command:
    id: <uuid>
    type: AI_ASSERTION
    assertion: "Description of what the page should look like"
    timeout: 30
```

## Action: Debug

1. Find the results directory (default `/tmp/momentic-results`)
2. Unzip the run archive from `runs/*.zip`
3. Read `attempts/1/metadata.json` to get step-by-step results
4. For each FAILED step, report:
   - Which step number and what it was trying to do
   - The failure reason and message
   - View the `afterSnapshot` screenshot to see what the page looked like
5. Check `console.json` for browser errors (CORS, 404, etc.)
6. Suggest fixes based on common failure patterns:
   - **AssertionFailureError**: Assertion text doesn't match actual page state. Update assertion wording.
   - **Element not found**: `elementDescriptor` doesn't match visible elements. Make descriptor more specific or generic.
   - **Infrastructure failure**: Page didn't load. Check if servers are running. Use `--env dev` to avoid local frontend EMFILE issues.
   - **Timeout**: Increase timeout or add WAIT steps before assertions.

## Action: List

Glob for `*.test.yaml` files relative to the Momentic config location and list them with their descriptions.

## macOS EMFILE Workaround

The builder-app monorepo triggers `EMFILE: too many open files` when running the Nuxt dev server locally on macOS. Instead of fighting this:
- Use `--env dev` which uses the hosted frontend at `app-development.relevanceai.com`
- The test can set `localStorage api-url` to `localhost:8001` so API calls still go to the local backend
- This effectively tests local backend code without needing a local frontend

## Existing Test Locations

- **builder-app**: `apps/builder-app/momentic-tests/`
  - Login module: `modules/login-builder-app.module.yaml`
  - Config: `apps/builder-app/momentic.config.yaml`
- **chat-app**: Check `momentic-tests/` in the chat-app repo
  - Login module: `momentic-tests/modules/login-chat-app.module.yaml`
  - Config: `momentic.config.yaml` at repo root
