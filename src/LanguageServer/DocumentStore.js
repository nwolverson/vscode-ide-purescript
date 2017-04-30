"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getDocuments = function (documents) { return function () { return documents.all(); }; };
exports.getDocument = function (documents) { return function (uri) { return function () { return documents.get(uri); }; }; };
