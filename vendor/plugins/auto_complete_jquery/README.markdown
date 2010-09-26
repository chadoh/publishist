AutoComplete for Jquery
=======================

This plugin provides a auto-complete method for your controllers to be used
with Dylan Verheul's jquery autocomplete plugin.  This version includes the plugin and macro methods
to get you up and running fast.

This auto_complete_jquery plugin is just a modified version of the standard
Rails auto_complete plugin.  It provides the same auto_complete_for method
for your controllers, but eliminates the various view helper methods, as
those are not needed when using jQuery and Unobtrusive JavaScript.

To use this, you need to have jQuery and the autocomplete plugin mentioned 
above, as well as appropriate CSS.  A modified plugin and CSS are included.

REQUIREMENTS:
=============

- JQuery (http://jquery.com)

INSTALLATION:
=============

Install this plugin 

      ./script/plugin install git://github.com/robertwahler/auto_complete_jquery.git

Copy the modified jquery.autocomplete.js and assets to your project's public folder 

       cp vendor/plugins/auto_complete_jquery/images/indicator.gif public/images/
       cp vendor/plugins/auto_complete_jquery/javascripts/jquery.autocomplete.js public/javascripts/
       cp vendor/plugins/auto_complete_jquery/stylesheets/jquery.autocomplete.css public/stylesheets/

or use the task:

       rake autocomplete:install

Add the javascript and CSS to your layout

Insert something similar to the following into the controller that you are working on:

        class BlogController < ApplicationController
          auto_complete_for :post, :title
        end

Now insert the following into application.js or anywhere where you are loading events for Jquery:

        $(document).ready(function() {
           $("input#post_title").autocomplete("auto_complete_for_post_title")
         });

What if you want to stay DRY and keep your controllers clean? Say you have the following
setup in one of your controllers:

        class UsersController < ApplicationController
          auto_complete_for :user, [:first_name, :last_name]
        end

And you want to use it in a view located in "/blogs", adjust your code in application.js like so:

        $(document).ready(function() {
           $("input#post_title").autocomplete("auto_complete_for_post_title")
           // call it by its full path
           $("input#user_name").autocomplete("/users/auto_complete_for_user_first_name_last_name")
         });

If you have many autocompletes, you could iterate over the entire page with jQuery's $.each.


Here's what the view might look like:

        <% form_for @post do |f| %>
          ....
          <%= f.text_field :title %>
          ...
        <% end %>  

__Note: for associations, you will need a hidden element to maintain the association id.__


USAGE:
======

auto_complete_for model, [:attrs], options={}
---------------------------------------------

auto_complete_for is a simple method to use, just call the method somewhere in your controller, I
usually call it at the top where I put my filters, etc.

###Standard format, name|id pairs suitable for association autocompletes:

    class BlogController < ApplicationController
      # returns jquery ready array with each element in form of:  "title|id\ntitle|id"
      auto_complete_for :post, :title
    end

###Simple format, skip the id and remove dupicates for simple string autocompletes:

    class BlogController < ApplicationController
      # returns jquery ready array with each element in form of:  "title|\ntitle|\ntitle"
      auto_complete_for :post, :title, :select => "distinct title"
    end

###Format the return string manually, just use the "id" by passing in a block:

    class BlogController < ApplicationController
      # returns jquery ready string with in form of:  "id|\nid|\n"
      auto_complete_for :post, :title  do |items|
        items.map{ |item| item.id }.join("\n")
      end 
    end

###To return multiple attributes:

    class Roles < ApplicationController
      # returns jquery ready string with in form of:  
      # "first_name last_name|id\nfirst_name last_name|id\n"
      auto_complete_for :user, [:first_name, :last_name]
    end

###To return multiple attributes with a delimiter:

    class BlogController < ApplicationController
      # returns jquery ready string with in form of:  
      # "title, created_at|id\ntitle, created_at|id\n"
      auto_complete_for :post, [:title, :created_at], :delimiter => ","
    end

###Skip SQL and use and instance variable 

    class BlogController < ApplicationController
      # pass in the name of an instance variable w/o the '@' to bypass
      # SQL and provide autocomplete from a collection.  Currently, this
      # only works for single methods not an array of methods.  
      #
      # pull data from @tags, no SQL used:
      # returns jquery ready string with in form of:  
      # "name|id\nname|id\n"
      auto_complete_for :tag, :name, :collection_instance_variable => :tags
    end

Options hash
------------

     See the source for more undocumented options


JS Readme (http://dyve.net/jquery/autocomplete.txt)
===================================================

For more information, see:
* jQuery site: http://jquery.com
* Dylan Verheul jquery autocomplete plugin site: http://www.dyve.net/jquery/?autocomplete
* Good article on jQuery and Rails (note this mentions a different jquery autocomplete 
  plugin, which was originally used in this plugin): http://errtheblog.com/posts/73-the-jskinny-on-jquery
* Original Rails auto_complete plugin: http://github.com/rails/auto_complete


Copyright (c) 2008 Cobalt Edge LLC, released under the MIT license.

Autocomplete - a jQuery plugin
==============================

Usage:
======
$("selector").autocomplete(url [, options]);

Demo page (search for English bird names, type "com" for example):
==================================================================
http://www.dyve.net/jquery?autocomplete

Advice:
=======
Make sure that selector selects only one element, unless you really, really know what you are doing.

Example:
========
$("#input_box").autocomplete("my_autocomplete_backend.php");

In the above example, Autocomplete expects an input element with the id "input_box" to exist. When a user starts typing in the input box, the autocompleter will request my_autocomplete_backend.php with a GET parameter named q that contains the current value of the input box. Let's assume that the user has typed "foo"(without quotes). Autocomplete will then request my_autocomplete_backend.php?q=foo.

The backend should output possible values for the autocompleter, each on a single line. Output cannot contain the pipe symbol "|", since that is considered a separator (more on that later).

An appropiate simple output would be:

foo
fool
foot
footloose
foo fighters
food fight

Note that the autocompleter will present the options in the order the backend sends them.


Advanced options:
=================

You can pass advanced options as a JavaScript object, notation { name:value, ..., name: value }
Example: $("#input_box").autocomplete("my_autocomplete_backend.php", { minChars:3 });

These options are available:

inputClass (default value: "ac_input")
        This class will be added to the input box.

resultsClass (default value: "ac_results")
        The class for the UL that will contain the result items (result items are LI elements).

loadingClass = (default value: "ac_loading")
        The class for the input box while results are being fetched from the server.

lineSeparator = (default value: "\n")
        The character that separates lines in the results from the backend.

cellSeparator (default value: "|")
        The character that separates cells in the results from the backend.

minChars (default value: 1)
        The minimum number of characters a user has to type before the autocompleter activates.

delay (default value: 400)
        The delay in milliseconds the autocompleter waits after a keystroke to activate itself.

cacheLength (default value: 1)
        The number of backend query results to store in cache. If set to 1 (the current result), no caching will happen. Do not set below 1.

matchSubset (default value: 1)
        Whether or not the autocompleter can use a cache for more specific queries. This means that all matches of "foot" are a subset of all matches for "foo". Usually this is true, and using this options decreases server load and increases performance. Remember to set cacheLength to a bigger number, like 10.

matchCase (default value: 0)
        Whether or not the comparison is case sensitive. Only important only if you use caching.

matchContains = options.matchContains || 0;
        Whether or not the comparison looks inside (i.e. does "ba" match "foo bar") the search results. Only important if you use caching.

mustMatch (default value: 0)
        If set to 1 (true), the autocompleter will only allow results that are presented by the backend. Note that illegal values result in an empty input box. In the example at the beginning of this documentation, typing "footer" would result in an empty input box.

extraParams (default value: {})
        Extra parameters for the backend. If you were to specify { bar:4 }, the autocompleter would call my_autocomplete_backend.php?q=foo&bar=4 (assuming the input box contains "foo").

selectFirst (default value: false)
        If this is set to true, the first autocomplete value will be automatically selected on tab/return, even if it has not been handpicked by keyboard or mouse action. If there is a handpicked (highlighted) result, that result will take precedence.

selectOnly (default value: false)
        If this is set to true, and there is only one autocomplete when the user hits tab/return, it will be selected even if it has not been handpicked by keyboard or mouse action. This overrides selectFirst.

formatItem (default value: none)
        A JavaScript funcion that can provide advanced markup for an item. For each row of results, this function will be called. The returned value will be displayed inside an LI element in the results list. Autocompleter will provide 3 parameters: the results row, the position of the row in the list of results, and the number of items in the list of results. See the source code of http://www.dyve.net/jquery?autocomplete for an example.

onItemSelect (default value: none)
        A JavaScript funcion that will be called when an item is selected. The autocompleter will specify a single argument, being the LI element selected. This LI element will have an attribute "extra" that contains an array of all cells that the backend specified. See the source code of http://www.dyve.net/jquery?autocomplete for an example.


More advanced options
=====================

If you want to do more with your autocompleter, you can change some options on the fly.
The autocompleter is accessed as an attribute of the input box.

Example:
$("#input_box").autocomplete("my_autocomplete_backend.php"); // Set the autocompleter
var ac = $("#input_box")[0].autocompleter; // A handle to our autocompleter

There are currently 2 functions that can be called to influence the behaviour at run-time:

flushCache()
        This flushes the cache.

setExtraParams(obj)
        This sets the extra parameters of the autocompleter to obj (which should be a JavaScript object, see above).

It's often wise to flush the cache after calling setExtraParameters.
