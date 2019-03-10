# make start an npm project
npm install npm@latest -global
npm init -yes

# install node plugins
npm install eslint@latest -global
npm install eslint@latest --save-dev
npm install gulp@latest -global
npm install gulp@latest --save-dev
npm install gulp-concat@latest -global
npm install gulp-concat@latest --save-dev
npm install gulp-sass@latest -global
npm install gulp-sass@latest --save-dev
npm install gulp-autoprefixer@latest -global
npm install gulp-autoprefixer@latest --save-dev
npm install gulp-uglifycss@latest -global
npm install gulp-uglifycss@latest --save-dev
npm install gulp-uglify-es@latest -global
npm install gulp-uglify-es@latest --save-dev
npm install gulp-rename@latest -global
npm install gulp-rename@latest --save-dev
npm install gulp-postcss@latest -global
npm install gulp-postcss@latest --save-dev
npm install gulp-sourcemaps@latest -global
npm install gulp-sourcemaps@latest --save-dev
npm install gulp-download@latest -global
npm install gulp-download@latest --save-dev

# (re)create the gulp file
touch gulpfile.js
: > ./gulpfile.js
echo "// import necessary plugins
const gulp         = require('gulp');
const concat       = require('gulp-concat');
const sass         = require('gulp-sass');
const rename       = require('gulp-rename');
const sourcemaps   = require('gulp-sourcemaps');
const postcss      = require('gulp-postcss');
const autoprefixer = require('gulp-autoprefixer');
const uglify_js    = require('gulp-uglify-es').default;
const download     = require('gulp-download');

const vendor_script_downloads = {
    '00_jquery-3.3.1.min.js': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js',
    '01_jquery-ui-1.12.1.min.js' : 'https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js'
};

// default task; required by gulp
gulp.task('default', () => { 
    download_vendor_scripts();
    return gulp.src('*.*', {read: false})
        .pipe(gulp.dest('./build_sources/styles/'))
        .pipe(gulp.dest('./build_sources/scripts/application'))
        .pipe(gulp.dest('./build_sources/scripts/vendors'))
        .pipe(gulp.dest('./wwwroot/css'))
        .pipe(gulp.dest('./wwwroot/js'))
        ;
});

// stylesheet compiler
/** get the sources of stylesheets to compile
 * @returns {object} an enumerable gulp source object */
let get_stylesheet_pipeline_source = () => gulp.src('./build_sources/styles/primary.scss');

/** compile the css file and deploy to the application folder
 * @returns {object} gulp pipeline for the deployed stylesheet */
let deploy_stylesheet = () => {
    return get_stylesheet_pipeline_source()
        .pipe(rename('site.min.css'))
        .pipe(sass({ outputStyle: 'compressed' }))
        .pipe(autoprefixer({ browsers: ['last 3 versions', '> 5%', 'Firefox ESR'] }))
        .pipe(gulp.dest('./wwwroot/css/'));
};

// script compiler
/** get the sources of the scripts to compile
 * @returns {object} an enumerable gulp source object */
let get_scripts_pipeline_source = () => gulp.src([
    './build_sources/scripts/vendors/**/*.js',
    './build_sources/scripts/application/**/*.js'
]).pipe(concat('concatenated_scripts.js'));

/** compile the js file and deploy to the application folder
 * @returns {object} gulp pipeline the deployed script */
let deploy_script = () => {
    return get_scripts_pipeline_source()
        .pipe(rename('site.js'))
        .pipe(sourcemaps.init())
        .pipe(gulp.dest('./wwwroot/js/'))
        .pipe(uglify_js())
        .pipe(sourcemaps.write())
        .pipe(rename('site.min.js'))
        .pipe(gulp.dest('./wwwroot/js/'))
        ;
};

// gulp tasks
gulp.task('deploy_stylesheet', () => deploy_stylesheet() );
gulp.task('deploy_script', () => deploy_script() );
gulp.task('download_vendor_scripts', (done) => { download_vendor_scripts(); done(); } );

gulp.task('watch', () => {
    gulp.watch('./build_sources/scripts/**/*.js', gulp.series([ 'deploy_script' ]));
    gulp.watch('./build_sources/styles/**/*.scss', gulp.series([ 'deploy_stylesheet' ]));
});

// utility functions
var download_vendor_scripts = () => {
    for (var file_name in vendor_script_downloads) {
        if (vendor_script_downloads.hasOwnProperty(file_name)) {
            download(vendor_script_downloads[file_name])
                .pipe(rename(file_name))
                .pipe(gulp.dest('./build_sources/scripts/vendors/'));
        }
    }
};" >> ./gulpfile.js

gulp # execute the default task, which should add the necessary file structure
touch ./wwwroot/index.html
echo '<!DOCTYPE html>
<html>
<head>
    <title>SPA</title>
    <link rel="stylesheet" type="text/css" href="/css/site.min.css">
</head>
<body>
    <div>
        <h3>hello world</h3>
    </div>

    <script src="/js/site.min.js"></script>
</body>
</html>' >> ./wwwroot/index.html

touch ./build_sources/styles/primary.scss

gulp deploy_stylesheet
gulp deploy_script

gulp watch & cd wwwroot; python -m SimpleHTTPServer
