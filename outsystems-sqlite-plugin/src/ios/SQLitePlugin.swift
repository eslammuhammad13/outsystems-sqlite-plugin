import Foundation
import SQLite3

@objc(SQLitePlugin)
class SQLitePlugin: CDVPlugin {

    var db: OpaquePointer?

    @objc(select:)
    func select(command: CDVInvokedUrlCommand) {

        let dbName = command.arguments[0] as? String ?? ""
        let query = command.arguments[1] as? String ?? ""

        let dbPath = getDBPath(dbName: dbName)

        if sqlite3_open(dbPath, &db) != SQLITE_OK {

            sendError("Cannot open database", command: command)
            return
        }

        var statement: OpaquePointer?

        var resultArray: [[String: Any]] = []

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {

            while sqlite3_step(statement) == SQLITE_ROW {

                var row: [String: Any] = [:]

                let columnCount = sqlite3_column_count(statement)

                for i in 0..<columnCount {

                    let name = String(cString: sqlite3_column_name(statement, i))

                    let type = sqlite3_column_type(statement, i)

                    switch type {

                    case SQLITE_INTEGER:
                        row[name] = sqlite3_column_int64(statement, i)

                    case SQLITE_FLOAT:
                        row[name] = sqlite3_column_double(statement, i)

                    case SQLITE_TEXT:
                        row[name] = String(cString: sqlite3_column_text(statement, i))

                    default:
                        row[name] = NSNull()
                    }
                }

                resultArray.append(row)
            }

            sqlite3_finalize(statement)

            sendSuccess(resultArray, command: command)

        } else {

            sendError("Query failed", command: command)
        }

        sqlite3_close(db)
    }

    private func getDBPath(dbName: String) -> String {

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)

        let docs = paths[0]

        return "\(docs)/\(dbName)"
    }

    private func sendSuccess(_ data: Any, command: CDVInvokedUrlCommand) {

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: data
        )

        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    private func sendError(_ message: String, command: CDVInvokedUrlCommand) {

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: message
        )

        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
}