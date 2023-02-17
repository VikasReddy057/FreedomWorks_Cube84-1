@isTest
public class ListSubscriptionJsonTest {
    @isTest static void testParse() {
        String json=		' {'+
            '        "mailingId": null,'+
            '        "listId": 110,'+
            '        "recipientId": 896423,'+
            '        "status": "NORMAL",'+
            '        "confirmed": false,'+
            '        "sourceId": null,'+
            '        "dateUnsub": null,'+
            '        "dateJoined": "2020-01-07T14:07:21Z",'+
            '        "address": "ppjjay1@gmail.com"'+
            '    }';
        ListSubscriptionJson obj = ListSubscriptionJson.parse(json);
        System.assert(obj != null);
    }
    @isTest static void testParseList() {
        String json=		' [{'+
            '        "mailingId": null,'+
            '        "listId": 110,'+
            '        "recipientId": 896423,'+
            '        "status": "NORMAL",'+
            '        "confirmed": false,'+
            '        "sourceId": null,'+
            '        "dateUnsub": null,'+
            '        "dateJoined": "2020-01-07T14:07:21Z",'+
            '        "address": "ppjjay1@gmail.com"'+
            '    }]';
        ListSubscriptionJson[] obj = ListSubscriptionJson.parseList(json);
        System.assert(obj != null);
    }
}