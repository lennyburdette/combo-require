//= require vendor/LAB
//= require_self

(function ($LAB) {
  
  var config;
  var modules = {};
  var _sorted;
  var _cachedURLs = {};
  
  // called when a module is loaded, registering it for use by
  // calls to `required`. unlike the real require.js, this assumes
  // that all dependencies have already been loaded because we have
  // a full dependency map ahead of time.
  function define (name, dependencies, definition) {
    var requiredModules = [], i, depName;
    for (i = -1; depName = dependencies[++i]; ) {
      requiredModules.push(modules[depName]);
    }
    
    modules[name] = definition.apply(window, requiredModules);
  }
  define.amd = { jQuery: true }; // https://github.com/jquery/jquery/blob/master/src/exports.js#L4

  // uses LABjs to load dependencies as provided by `configure`, then
  // execute the callback providing the modules as arguments
  function require (dependencies, callback) {
    var scripts = sortAndCombineModules(dependencies),
        i, script, depName, requiredModules = [],
        chain = $LAB.wait();
    
    for (i = -1; script = scripts[++i]; ) {
      chain.script(script).wait();
    }
    
    chain.wait(function () {
      for (i = -1; depName = dependencies[++i]; ) {
        requiredModules.push(modules[depName]);
      }
      
      // and the magic happens!
      callback.apply(window, requiredModules);
    });
  }
  
  // adds a few default configuation vars
  function configure (c) {
    config = reverseMerge(c, {
      base: "",
      comboBase: "",
      combine: false,
      prefix: "",
      comboPrefix: ""
    });
  }
  
  // turns a sorted list of dependencies into URLs, potentially
  // combining them for delivering by a combo server
  function sortAndCombineModules (deps) {
    _sorted = _sorted || _sort();
    var all = allModulesForDependencies(deps),
        urls = [], i, l, module,
        current = [], fullUrl, paths;
    
    // adds a URL for a single module to the URL list
    function commitFull (name, path) {
      fullUrl = config.base + config.prefix + config.modules[module].path;
      urls.push(fullUrl);
      _cachedURLs[module] = fullUrl;
    }
    
    // adds a combo URL for multiple modules to the URL list
    function commitCombo () {
      if (! current || ! current.length) return;
      
      paths = [];
      for (i = 0, l = current.length; i < l; i++) {
        paths.push( config.comboPrefix + config.modules[current[i]].path );
      }
      fullUrl = config.comboBase + paths.join("&");
      urls.push(fullUrl);
      
      // save this combo url for all the applicable modules
      for (i = 0; i < l; i++) {
        _cachedURLs[current[i]] = fullUrl;
      }
      // clear the current combo list for the next pass
      current = [];
    }
    
    // loop through the sorted array
    for (i = -1; module = _sorted[++i]; ) {
      // but only pay attention to the needed dependencies
      if (all.indexOf(module) > -1) {
        
        // if a module has already been requested, re-add the previous URL
        // to the URL list. LABjs will take care of not re-requesting it.
        if (_cachedURLs[module]) {
          commitCombo(current);
          urls.push(_cachedURLs[module]);
          continue;
        }
        
        // this module will be loaded in a combo URL
        if (config.combine && config.modules[module].combined !== false) {
          current.push(module);
          
        // this module will be loaded separately
        } else {
          commitCombo(current);
          commitFull(module, config.modules[module].path);
        }
        
      }
    }
    
    // if we haven't add the last known combo URL to the list
    commitCombo(current);
    return uniqAndCompact(urls);
  }
  
  function allModulesForDependencies (deps) {
    var all = deps, i, dep;
    
    for (i = -1; dep = deps[++i]; ) {
      if (config.modules[dep]) {
        all = all.concat(config.modules[dep].requires || []);
        all = all.concat( allModulesForDependencies(config.modules[dep].requires || []) );
      } else {
        throw new Error("Missing module definition: " + dep);
      }
    }
    
    return uniqAndCompact(all);
  }
  
  // https://github.com/yui/yui3/blob/master/src/loader/js/loader.js#L2101
  function _sort () {
    var s = keys(config.modules);
    
    // create an indexed list
    var s = keys(config.modules),
        done = {},
        p = 0, l, a, b, j, k, moved, doneKey;

    // keep going until we make a pass without moving anything
    for (;;) {

        l = s.length;
        moved = false;

        // start the loop after items that are already sorted
        for (j = p; j < l; j++) {

            // check the next module on the list to see if its
            // dependencies have been met
            a = s[j];

            // check everything below current item and move if we
            // find a requirement for the current item
            for (k = j + 1; k < l; k++) {
                doneKey = a + s[k];

                if (!done[doneKey] && _requires(a, s[k])) {

                    // extract the dependency so we can move it up
                    b = s.splice(k, 1);

                    // insert the dependency above the item that
                    // requires it
                    s.splice(j, 0, b[0]);

                    // only swap two dependencies once to short circuit
                    // circular dependencies
                    done[doneKey] = true;

                    // keep working
                    moved = true;

                    break;
                }
            }

            // jump out of loop if we moved something
            if (moved) {
                break;
            // this item is sorted, move our pointer and keep going
            } else {
                p++;
            }
        }

        // when we make it here and moved is false, we are
        // finished sorting
        if (!moved) {
            break;
        }

    }

    return s;
  }
  
  // Recursively checks if module `a` requires module `b`
  function _requires (a, b) {
    var aDeps = config.modules[a].requires, i, l;
    
    if (aDeps && aDeps.length) {
      if (aDeps.indexOf(b) > -1) {
        return true;
      } else {
        for (i = 0, l = aDeps.length; i < l; i++) {
          if (_requires(aDeps[i], b)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  // Utilities
  
  function keys (object) {
    var all = [], k;
    for (k in object) if (object.hasOwnProperty(k)) all[all.length] = k;
    return all;
  }
  
  function reverseMerge(o, m) {
    for (var key in m) {
      if (m.hasOwnProperty(key) && !(key in o)) {
        o[key] = m[key];
      }
    }
    return o;
  }
  
  function uniqAndCompact (array) {
    if (! array || ! array.length) return null;
    
    var result = [array[0]], i, l;
    for (i = 1, l = array.length; i < l; i++) {
      if ( array[i] !== null && result.indexOf(array[i]) === -1 ) {
        result.push(array[i]);
      }
    }
    return result;
  }
  
  // Exports
  
  this.define = define;
  this.require = require;
  this.configure = configure;
  
}).call(this, $LAB);
