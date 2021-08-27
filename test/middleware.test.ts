import { middleware, registerMiddleware, unregisterMiddleware } from '../src/middleware'

test('middleware', () => {
  let res = 0;
  middleware.didOpen(null, () => {});
  expect(res).toBe(0);
  const myMiddleware = {
    didOpen: (data, next) => { res++; next(data); }
  }
  registerMiddleware(myMiddleware);
  middleware.didOpen(null, () => {});
  expect(res).toBe(1);
  registerMiddleware({
    didOpen: (data, next) => { res += 42; next(data); }
  });
  middleware.didOpen(null, () => {});
  expect(res).toBe(44);
  unregisterMiddleware(myMiddleware);
  middleware.didOpen(null, () => {});
  expect(res).toBe(86);
});