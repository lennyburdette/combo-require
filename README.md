Combo Require
=============

Combo Require is a Rails engine that provides a simplified version AMD/requirejs for the asset pipeline with combo loading.

Usage
-----

### app/views/layouts/application.html.erb

    <%= javascript_include_tag "combo-require" %>
    <script type="text/javascript">
      configure({
        base: "/assets/",
        combine: true,
        comboBase: "/combo?",
        modules: <%= module_map %>
      });
    </script>
    <script type="text/javascript">
      require(["my-module"], function ($, myModule) {
        myModule(); // writes Hello World! to the page.
      });
    </script>

### app/assets/javascripts/my-module.js

    define("my-module", ["jquery"], function ($) {
      return function () {
        $(document.body).html("Hello World!");
      };
    });
    
How it works
------------

* The ComboRequire::ModuleMap class reads all the files in the asset pipeline,
looks for calls to `define()`, and creates a dependency tree that can be embedded
in a `<script>` block.
* Simple versions of `require()` and `define()` use the dependency tree to build combo
URLs like `/combo?jquery.js&my-module.js`.
* The ComboRequire::ComboController concatenates each file in the combo URL into a single file.
* `require()` offloads the actual loading of JavaScript files to LABjs.

Caveats
-------

* Combination URLs skip the asset pipeline and are rendered on every request.
* Cannot use Sprocket's MD5 digested URLs.
* Finding the `define` calls in source files is a really simple regular expression
and will probably break.
* Differences from requirejs:
  * Anonymous module definitions are not supported.
  * No plugins (but there's crappy support for handlebars built in right now.)
  * Calls to `define` will not load unloaded modules, because it assumes that the `require`
    took care of them using the dependency tree.

To Do
-----

* Cache control headers on the combo server.
* Configurable CDN combo hosts.
* Figure out versioning.
* Clean up handlebars.js support (it's super hacky and relies on the sht_rails gem right now.)
* Add caching to the ModuleMap class.
* Add JS compression.

License
-------

Copyright (c) 2012 Lenny Burdette

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
