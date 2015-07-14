## v0.3.0
 - Replace home grown locking mechanism with the ZK gem's implementation of
   [Lock][http://zookeeper.apache.org/doc/trunk/recipes.html#sc_recipes_Locks]
 - Updated Docs for usage
 - implement Clocker.held? helper method for use with not_if/only_if guards

## v0.2.0
 - Add some debug logging
 - Support for wait and retries on clockon
 - Removal of unused id parameter for exists?
 - rubocop and foodcritic linting and style
 - Removal of zk_test testing cookbook

## v0.1.0
 - Initial release, supports clockon, clockoff, exists and flockoff
