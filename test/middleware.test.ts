import { middleware, registerMiddleware, unregisterMiddleware } from '../src/middleware'

test('middleware', () => {
  let res = 0;
  middleware.didOpen(null, () => Promise.resolve());
  expect(res).toBe(0);
  const myMiddleware = {
    didOpen: (data, next) => { res++; next(data); return Promise.resolve(); }
  }
  registerMiddleware(myMiddleware);
  middleware.didOpen(null, () => Promise.resolve());
  expect(res).toBe(1);
  registerMiddleware({
    didOpen: (data, next) => { res += 42; next(data); return Promise.resolve(); }
  });
  middleware.didOpen(null, () => Promise.resolve());
  expect(res).toBe(44);
  unregisterMiddleware(myMiddleware);
  middleware.didOpen(null, () => Promise.resolve());
  expect(res).toBe(86);
});