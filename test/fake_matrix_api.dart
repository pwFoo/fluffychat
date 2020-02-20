import 'package:http/testing.dart';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:http/http.dart';

class FakeMatrixApi extends MockClient {
  FakeMatrixApi()
      : super((request) async {
          // Collect data from Request
          final String action = request.url.path.split("/_matrix")[1];
          final String method = request.method;
          final dynamic data =
              method == "GET" ? request.url.queryParameters : request.body;
          var res = {};

          //print("$method request to $action with Data: $data");

          // Sync requests with timeout
          if (data is Map<String, dynamic> && data["timeout"] is String) {
            await Future.delayed(Duration(seconds: 5));
          }

          // Call API
          if (api.containsKey(method) && api[method].containsKey(action)) {
            res = api[method][action](data);
          } else if (method == "GET" &&
              action.contains("/client/r0/rooms/") &&
              action.contains("/state/m.room.member/")) {
            res = {"displayname": ""};
            return Response(json.encode(res), 200);
          } else {
            res = {
              "errcode": "M_UNRECOGNIZED",
              "error": "Unrecognized request"
            };
          }

          return Response(json.encode(res), 100);
        });

  static final Map<String, Map<String, dynamic>> api = {
    "GET": {
      "/client/versions": (var req) => {
            "versions": ["r0.0.1", "r0.1.0", "r0.2.0", "r0.3.0", "r0.4.0"],
            "unstable_features": {"m.lazy_load_members": true},
          },
      "/client/r0/account/whoami": (var req) =>
          {"user_id": "@test:fakeServer.notExisting"},
      "/client/r0/login": (var req) => {
            "flows": [
              {"type": "m.login.password"}
            ]
          },
      "/client/r0/sync": (var req) => {
            "next_batch": Random().nextDouble().toString(),
            "presence": {
              "events": [
                {
                  "sender": "@alice:example.com",
                  "type": "m.presence",
                  "content": {"presence": "online"}
                }
              ]
            },
            "account_data": {
              "events": [
                {
                  "type": "org.example.custom.config",
                  "content": {"custom_config_key": "custom_config_value"}
                }
              ]
            },
            "to_device": {
              "events": [
                {
                  "sender": "@alice:example.com",
                  "type": "m.new_device",
                  "content": {
                    "device_id": "XYZABCDE",
                    "rooms": ["!726s6s6q:example.com"]
                  }
                }
              ]
            },
            "rooms": {
              "join": {
                "!726s6s6q:example.com": {
                  "unread_notifications": {
                    "highlight_count": 2,
                    "notification_count": 2,
                  },
                  "state": {
                    "events": [
                      {
                        "sender": "@alice:example.com",
                        "type": "m.room.member",
                        "state_key": "@alice:example.com",
                        "content": {"membership": "join"},
                        "origin_server_ts": 1417731086795,
                        "event_id": "66697273743031:example.com"
                      }
                    ]
                  },
                  "timeline": {
                    "events": [
                      {
                        "sender": "@bob:example.com",
                        "type": "m.room.member",
                        "state_key": "@bob:example.com",
                        "content": {"membership": "join"},
                        "prev_content": {"membership": "invite"},
                        "origin_server_ts": 1417731086795,
                        "event_id": "7365636s6r6432:example.com"
                      },
                      {
                        "sender": "@alice:example.com",
                        "type": "m.room.message",
                        "txn_id": "1234",
                        "content": {"body": "I am a fish", "msgtype": "m.text"},
                        "origin_server_ts": 1417731086797,
                        "event_id": "74686972643033:example.com"
                      }
                    ],
                    "limited": true,
                    "prev_batch": "t34-23535_0_0"
                  },
                  "ephemeral": {
                    "events": [
                      {
                        "type": "m.typing",
                        "content": {
                          "user_ids": ["@alice:example.com"]
                        }
                      }
                    ]
                  },
                  "account_data": {
                    "events": [
                      {
                        "type": "m.tag",
                        "content": {
                          "tags": {
                            "work": {"order": 1}
                          }
                        }
                      },
                      {
                        "type": "org.example.custom.room.config",
                        "content": {"custom_config_key": "custom_config_value"}
                      }
                    ]
                  }
                }
              },
              "invite": {
                "!696r7674:example.com": {
                  "invite_state": {
                    "events": [
                      {
                        "sender": "@alice:example.com",
                        "type": "m.room.name",
                        "state_key": "",
                        "content": {"name": "My Room Name"}
                      },
                      {
                        "sender": "@alice:example.com",
                        "type": "m.room.member",
                        "state_key": "@bob:example.com",
                        "content": {"membership": "invite"}
                      }
                    ]
                  }
                }
              },
              "leave": {
                "!5345234234:example.com": {
                  "timeline": {"events": []}
                },
              },
            }
          },
    },
    "POST": {
      "/client/r0/keys/claim": (var req) => {
            "failures": {},
            "one_time_keys": {
              "@alice:example.com": {
                "JLAFKJWSCS": {
                  "signed_curve25519:AAAAHg": {
                    "key": "zKbLg+NrIjpnagy+pIY6uPL4ZwEG2v+8F9lmgsnlZzs",
                    "signatures": {
                      "@alice:example.com": {
                        "ed25519:JLAFKJWSCS":
                            "FLWxXqGbwrb8SM3Y795eB6OA8bwBcoMZFXBqnTn58AYWZSqiD45tlBVcDa2L7RwdKXebW/VzDlnfVJ+9jok1Bw"
                      }
                    }
                  }
                }
              }
            }
          },
      "/client/r0/keys/upload": (var req) => {
            "one_time_key_counts": {
              "curve25519": 10,
              "signed_curve25519": 100,
            }
          },
      "/client/r0/keys/query": (var req) => {
            "failures": {},
            "device_keys": {
              "@test:fakeServer.notExisting": {
                "JLAFKJWSCS": {
                  "user_id": "@test:fakeServer.notExisting",
                  "device_id": "JLAFKJWSCS",
                  "algorithms": [
                    "m.olm.v1.curve25519-aes-sha2",
                    "m.megolm.v1.aes-sha2"
                  ],
                  "keys": {
                    "curve25519:JLAFKJWSCS":
                        "3C5BFWi2Y8MaVvjM8M22DBmh24PmgR0nPvJOIArzgyI",
                    "ed25519:JLAFKJWSCS":
                        "lEuiRJBit0IG6nUf5pUzWTUEsRVVe/HJkoKuEww9ULI"
                  },
                  "signatures": {
                    "@test:fakeServer.notExisting": {
                      "ed25519:JLAFKJWSCS":
                          "dSO80A01XiigH3uBiDVx/EjzaoycHcjq9lfQX0uWsqxl2giMIiSPR8a4d291W1ihKJL/a+myXS367WT6NAIcBA"
                    }
                  },
                  "unsigned": {"device_display_name": "Alice's mobile phone"}
                }
              }
            }
          },
      "/client/r0/login": (var req) => {
            "user_id": "@test:fakeServer.notExisting",
            "access_token": "abc123",
            "device_id": "GHTYAJCE"
          },
      "/client/r0/logout": (var reqI) => {},
      "/client/r0/logout/all": (var reqI) => {},
    },
    "PUT": {
      "/client/r0/rooms/!request:localhost/state/com.famedly.app.request_state":
          (var req) => {"event_id": "1234"},
      "/client/r0/user/null/account_data/com.famedly.talk.tasks": (var req) =>
          {},
      "/client/r0/rooms/1234/typing/@test:fakeServer.notExisting": (var req) =>
          {},
    },
    "DELETE": {
      "/unknown/token": (var req) => {"errcode": "M_UNKNOWN_TOKEN"},
    },
  };
}
