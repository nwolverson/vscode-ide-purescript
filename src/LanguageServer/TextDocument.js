"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getText = function (document) { return function () { return document.getText(); }; };
exports.offsetAtPosition = function (document) { return function (pos) { return function () { return document.offsetAt(pos); }; }; };
exports.positionAtOffset = function (document) { return function (offset) { return function () { return document.positionAt(offset); }; }; };
