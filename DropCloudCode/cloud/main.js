
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


    console.log("Type is "+type);

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

function addNewUser(user)
{

}