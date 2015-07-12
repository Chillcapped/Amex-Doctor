module.exports = function(grunt) {
	grunt.initConfig({
	
	// End of Init
});
	
	
	///////////////////////////////
	// 		Tasks.
	//////////////////////////////
	
	// Default
  	grunt.registerTask('default', 
  			[ '']
  	);
  	
  	// Build
	///////////////////////////////
	// 		Dependencies
	//////////////////////////////
	
  	grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
};