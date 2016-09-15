var gulp = require('gulp');
var $    = require('gulp-load-plugins')();

var sassPaths = [
	'node_modules/bootstrap-sass/assets/stylesheets'
];

gulp.task('sass', function() {
  return gulp.src('public/scss/app.scss')
    .pipe($.sass({
      includePaths: sassPaths,
      outputStyle: 'compressed' // if css compressed **file size**
    })
      .on('error', $.sass.logError))
    .pipe($.autoprefixer({
      browsers: ['last 2 versions', 'ie >= 9']
    }))
    .pipe(gulp.dest('public/css'));
});

gulp.task('default', ['sass'], function() {
  gulp.watch(['public/scss/**/*.scss'], ['sass']);
});
