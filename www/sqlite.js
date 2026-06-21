var exec = require('cordova/exec');

module.exports = {

    select: function (dbName, sql, success, error) {

        exec(
            success,
            error,
            "SQLitePlugin",
            "select",
            [dbName, sql]
        );
    }

};