(function(global) {
  "use strict";

  // // Get Execution environment.
  // var isBrowser    = "document"       in global;
  // var isWebWorkers = "WorkerLocation" in global;
  // var isNode       = "process"        in global;
  
  // Class
  function MyModule()//{{{
  {
  }//}}}

  // Header
  MyModule.prototype.method = MyModule_method; // MyModule#method{a:any, b:int}:void

  // Implementation
  function MyModule_Method()//{{{
  {
  }//}}}

  // Exports
  // Support the require function of CommonJS Style.
  if ("process" in global) {
  // if (inNode) {
    module.exports = MyModule;
  }
  // Support the require function of CommonJS Style.
  global.MyModule = MyModule;
})( (this || 0).self || global );
