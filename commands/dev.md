# /dev -- Start Development Servers

Start both the frontend and backend development servers in parallel. Detect the project structure automatically and use the appropriate commands.

## Behavior

1. Detect the frontend directory (check for `frontend/`, `client/`, or `web/` in order).
2. Detect the backend directory (check for `backend/`, `api/`, or `server/` in order).
3. Detect the frontend package manager by checking for lock files (`pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`).
4. Detect the backend framework by checking for `pyproject.toml`, `requirements.txt`, or `Pipfile`.
5. Start both servers in parallel.

## Frontend Start Commands

Use the detected package manager to run the `dev` script:

- **pnpm**: `pnpm --prefix <frontend_dir> run dev`
- **yarn**: `yarn --cwd <frontend_dir> dev`
- **npm**: `npm --prefix <frontend_dir> run dev`

If no `dev` script exists in package.json, fall back to `start`.

## Backend Start Commands

Detect the framework and start accordingly:

- **FastAPI** (if `fastapi` is in dependencies): `uvicorn main:app --reload --host 0.0.0.0 --port 8000`
- **Django** (if `django` is in dependencies): `python manage.py runserver 0.0.0.0:8000`
- **Flask** (if `flask` is in dependencies): `flask run --host 0.0.0.0 --port 8000 --reload`

Run the backend command from within the detected backend directory. Activate the virtual environment first if `.venv/` or `venv/` exists in the backend directory.

## Execution

Run both processes concurrently. Use `&` for backgrounding or a process manager. Print output from both servers to the terminal with clear prefixes:

```
[frontend] Ready on http://localhost:5173
[backend]  Uvicorn running on http://0.0.0.0:8000
```

If either server fails to start, report the error clearly and keep the other server running.
