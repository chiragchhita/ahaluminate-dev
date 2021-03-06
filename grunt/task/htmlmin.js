/* jshint strict:false */

module.exports = {
  options: {
    collapseBooleanAttributes: true, 
    collapseWhitespace: true, 
    minifyCSS: true, 
    minifyJS: true, 
    removeComments: true, 
    removeEmptyAttributes: true, 
    removeScriptTypeAttributes: true, 
    removeStyleLinkTypeAttributes: true
  }, 
  
  "general": {
    files: [
      {
        expand: true, 
        cwd: 'src/general/html/', 
        src: [
          '**/*.*'
        ], 
        dest: "dist/general/html/"
      }
    ]
  }, 
  
  "heart-walk": {
    files: [
      {
        expand: true, 
        cwd: 'src/heart-walk/html/', 
        src: [
          '**/*.*'
        ], 
        dest: "dist/heart-walk/html/"
      }
    ]
  }, 
  
  "youth-markets": {
    files: [
      {
        expand: true, 
        cwd: 'src/youth-markets/html/', 
        src: [
          '**/*.*'
        ], 
        dest: "dist/youth-markets/html/"
      }
    ]
  }, 
  
  "jump-hoops": {
    files: [
      {
        expand: true, 
        cwd: 'src/jump-hoops/html/', 
        src: [
          '**/*.*'
        ], 
        dest: "dist/jump-hoops/html/"
      }
    ]
  }
}