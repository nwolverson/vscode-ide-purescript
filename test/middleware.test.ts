import { middleware, registerMiddleware, unregisterMiddleware } from '../src/middleware'

test('middleware', () => {
  let res = 0;
  middleware.didOpen(null, () => {});
  expect(res).toBe(0);
  registerMiddleware("my-middleware", {
    didOpen: (data, next) => { res++; next(data); }
  });
  middleware.didOpen(null, () => {});
  expect(res).toBe(1);
  registerMiddleware("my-other-middleware", {
    didOpen: (data, next) => { res += 42; next(data); }
  });
  middleware.didOpen(null, () => {});
  expect(res).toBe(44);
  unregisterMiddleware("my-middleware");
  middleware.didOpen(null, () => {});
  expect(res).toBe(86);
});