type EffectUnit = () => void;
let _diagnosticsBegin: EffectUnit = () => { }
export const setDiagnosticsBegin = (f: EffectUnit) => {
  _diagnosticsBegin = f;
}
export const diagnosticsBegin = () => {
  _diagnosticsBegin();
}
let _cleanBegin: EffectUnit = () => { }
export const setCleanBegin = (f: EffectUnit) => {
  _cleanBegin = f;
}
export const cleanBegin = () => {
  _cleanBegin();
}
let _diagnosticsEnd: EffectUnit = () => { }
export const setDiagnosticsEnd = (f: EffectUnit) => {
  _diagnosticsEnd = f;
}
export const diagnosticsEnd = () => {
  _diagnosticsEnd();
}
let _cleanEnd: EffectUnit = () => { }
export const setCleanEnd = (f: EffectUnit) => {
  _cleanEnd = f;
}
export const cleanEnd = () => {
  _cleanEnd();
}