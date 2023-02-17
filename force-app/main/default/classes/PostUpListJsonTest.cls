@isTest
public class PostUpListJsonTest {
    @isTest static void testParse() {
        String json=		'[{'+
            '        "listId": 2,'+
            '        "title": "Morning Update",'+
            '        "friendlyTitle": "",'+
            '        "description": "",'+
            '        "populated": true,'+
            '        "publicSignup": true,'+
            '        "globalUnsub": false,'+
            '        "query": "ListRecips.LISTID=2",'+
            '        "categoryId": 0,'+
            '        "blockDomains": "",'+
            '        "seedListId": 0,'+
            '        "createTime": "2016-06-27 10:34:43.983",'+
            '        "creator": "jneuren@postup.com",'+
            '        "externalId": "",'+
            '        "custom1": "",'+
            '        "channel": "E",'+
            '        "countRecips": true,'+
            '        "brandIds": ['+
            '            8,'+
            '            9,'+
            '            10,'+
            '            11'+
            '        ],'+
            '        "listCount": 14940,'+
            '        "testMessageList": false'+
            '    }]';
        PostUpListJson[] obj = PostUpListJson.parse(json);
        System.assert(obj != null);
    }
    @isTest static void testParsePostUpListJson() {
        String json=		'{'+
            '        "listId": 2,'+
            '        "title": "Morning Update",'+
            '        "friendlyTitle": "",'+
            '        "description": "",'+
            '        "populated": true,'+
            '        "publicSignup": true,'+
            '        "globalUnsub": false,'+
            '        "query": "ListRecips.LISTID=2",'+
            '        "categoryId": 0,'+
            '        "blockDomains": "",'+
            '        "seedListId": 0,'+
            '        "createTime": "2016-06-27 10:34:43.983",'+
            '        "creator": "jneuren@postup.com",'+
            '        "externalId": "",'+
            '        "custom1": "",'+
            '        "channel": "E",'+
            '        "countRecips": true,'+
            '        "brandIds": ['+
            '            8,'+
            '            9,'+
            '            10,'+
            '            11'+
            '        ],'+
            '        "listCount": 14940,'+
            '        "testMessageList": false'+
            '    }';
        PostUpListJson obj = PostUpListJson.parsePostUpListJson(json);
        System.assert(obj != null);
    }
}