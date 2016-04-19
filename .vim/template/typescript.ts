/*jshint latedef:false, sub:true */
/// <reference path="./typings/main.d.ts" />
(function(global: any) {
  "use strict";
  
  // let isBrowser    = "document" in global;
  // let isWebWorkers = "WorkerLocation" in global;
  // let isNode       = "process" in global;

  // Class ------------------------------------------------//{{{
  function YourModule()//{{{
  {
  }//}}}
  //}}}

  // Header -----------------------------------------------//{{{
  YourModule["prototype"]["method"] = YourModule_method; // YourModule#method(someArg:any):void
  //}}}
  
  // Implementation ---------------------------------------//{{{
  function YourModule_method(someArg)
  {
      // ...
  }
  //}}}
  
  // Exports ----------------------------------------------//{{{
  if ("process" in global) {
      module["exports"] = YourModule;
  }
  global["YourModule"] = YourModule;
  //}}}
})( (this || 0).self || global );
