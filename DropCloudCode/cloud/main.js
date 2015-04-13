
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
    response.success("Hello world!");
});



//After saving new post
//Check if the user exist in the users class
//if not, create user object and set the points value to 1

Parse.Cloud.afterSave("Posts", function(request) {

    var deviceId = request.object.get("deviceId");
    var location = request.object.get("location");
    var type = request.object.get("type");
    var postText = request.object.get('text');

    console.log(type);

    //Get the User object if it exist
    query = new Parse.Query("_User");
    query.equalTo("deviceId", deviceId);
    query.find({
        success: function(user) {

            var length = user.length;
            var userObject;

            if (length > 0)
            {
                userObject = user[0];
            }

            Parse.Cloud.useMasterKey();

            if (type == "New")
            {
                if (length == 0)
                {
                    //If the user does not exist
                    console.log("Creating A New User");
                    //Add a new user
                    newUser = new Parse.User();

                    newUser.set("username", deviceId);
                    newUser.set("password", deviceId);
                    newUser.set("deviceId", deviceId);
                    newUser.set("lastKnownLocation", location);
                    newUser.set("points", 1);

                    newUser.save();
                }else{
                    userObject.set("lastKnownLocation", location);
                    userObject.increment("points", 1);
                    userObject.save();
                }
            }else if (type == "Like"){
                if (length > 0)
                {
                    userObject.increment("points", 2);
                    userObject.save();


                    //Create a notification object and save it
                    var Notification = Parse.Object.extend("Notifications");
                    var notification = new Notification();
                    var message = "Someone liked your post: " + postText

                    notification.set("message", message);
                    notification.set("type", "Like");

                    notification.save(null, {
                        success: function(notification) {
                            // Execute any logic that should take place after the object is saved.
                            //send push notification
                            var authorDeviceId = userObject.get("deviceId");
                            var pushQuery = new Parse.Query(Parse.Installation);
                            pushQuery.equalTo('deviceId', authorDeviceId);

                            Parse.Push.send({
                                where: pushQuery, // Set our Installation query
                                data: {
                                    alert: message
                                }
                            }, {
                                success: function() {
                                    // Push was successful
                                    console.log("Pushed")
                                },
                                error: function(error) {
                                    throw "Got an error " + error.code + " : " + error.message;
                                }
                            });
                        },
                        error: function(notification, error) {
                            // Execute any logic that should take place if the save fails.
                            // error is a Parse.Error with an error code and message.
                            alert('Failed to create new object, with error code: ' + error.message);
                        }
                    });
                }
            }else if (type == "Dislike"){
                if (length > 0)
                {
                    userObject.increment("points", -2);
                    userObject.save();
                }
            }else if (type == "Report"){
                if (length > 0)
                {
                    userObject.increment("points", -5);
                    userObject.save();
                }
            }
        },
        error: function(error) {
            console.error("Got an error " + error.code + " : " + error.message);
        }
    });
});

Parse.Cloud.afterSave("Comments", function(request) {

    // Our "Comment" class has a "text" key with the body of the comment itself
    var commentText = request.object.get('text');
    var postId = request.object.get('postId');

    var commenterDeviceId = request.object.get('deviceId');


    var Post = Parse.Object.extend("Posts");
    var query = new Parse.Query(Post);
    query.equalTo("objectId", postId);
    query.find({
        success: function(post) {
            // The object was retrieved successfully.

            if (post.length > 0)
            {
                postObject = post[0];

                var deviceId = postObject.get("deviceId");

                if (deviceId != commenterDeviceId){

                    //Create a notification object and save it
                    var Notification = Parse.Object.extend("Notifications");
                    var notification = new Notification();
                    var message = "Someone left a comment on your post: " + commentText;

                    notification.set("message", message);
                    notification.set("type", "Comment");

                    notification.save(null, {
                        success: function(notification) {
                            // Execute any logic that should take place after the object is saved.
                            //send push
                            var pushQuery = new Parse.Query(Parse.Installation);
                            pushQuery.equalTo('deviceId', deviceId);

                            Parse.Push.send({
                                where: pushQuery, // Set our Installation query
                                data: {
                                    alert: message
                                }
                            }, {
                                success: function() {
                                    // Push was successful
                                    console.log("Pushed")
                                },
                                error: function(error) {
                                    throw "Got an error " + error.code + " : " + error.message;
                                }
                            });
                        },
                        error: function(notification, error) {
                            // Execute any logic that should take place if the save fails.
                            // error is a Parse.Error with an error code and message.
                            alert('Failed to create new object, with error code: ' + error.message);
                        }
                    });



                }
            }
        },
        error: function(object, error) {
            // The object was not retrieved successfully.
            // error is a Parse.Error with an error code and message.
        }
    });
});