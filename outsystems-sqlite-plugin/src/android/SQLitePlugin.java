package com.acme.outsystems.sqlite;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONObject;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.content.Context;

public class SQLitePlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {

        if ("select".equals(action)) {

            try {

                String dbName = args.getString(0);
                String sql = args.getString(1);

                SQLiteDatabase db = cordova.getActivity()
                        .openOrCreateDatabase(dbName, Context.MODE_PRIVATE, null);

                Cursor cursor = db.rawQuery(sql, null);

                JSONArray resultArray = new JSONArray();

                while (cursor.moveToNext()) {

                    JSONObject row = new JSONObject();

                    for (int i = 0; i < cursor.getColumnCount(); i++) {

                        String colName = cursor.getColumnName(i);

                        switch (cursor.getType(i)) {

                            case Cursor.FIELD_TYPE_INTEGER:
                                row.put(colName, cursor.getLong(i));
                                break;

                            case Cursor.FIELD_TYPE_FLOAT:
                                row.put(colName, cursor.getDouble(i));
                                break;

                            case Cursor.FIELD_TYPE_STRING:
                                row.put(colName, cursor.getString(i));
                                break;

                            case Cursor.FIELD_TYPE_NULL:
                            default:
                                row.put(colName, JSONObject.NULL);
                                break;
                        }
                    }

                    resultArray.put(row);
                }

                cursor.close();

                callbackContext.success(resultArray);

                return true;

            } catch (Exception e) {

                callbackContext.error(e.getMessage());
                return true;
            }
        }

        return false;
    }
}