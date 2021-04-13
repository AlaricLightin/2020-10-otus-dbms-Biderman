rs.initiate({"_id" : "RS3", members : [{"_id" : 0, priority : 3, host : "mongo_3_1"},
        {"_id" : 1, host : "mongo_3_2"},
        {"_id" : 2, host : "mongo_3_3", arbiterOnly : true}]});