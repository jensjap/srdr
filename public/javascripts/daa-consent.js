(function(){
    var app = angular.module('daaConsent', []);

    app.controller('PageController', ["$scope", function($scope){
        var pageCtrl = this;

        pageCtrl.activePage = 1;

        $scope.$watch('pageCtrl.activePage', function(newValue, oldValue){
            if (pageCtrl.activePage === 1) {
                document.getElementById("back").className = "fade";
            } else {
                document.getElementById("back").className = "";
            }
        });

        pageCtrl.nextPage = function(){
            if (pageCtrl.activePage < 9) {
                pageCtrl.activePage = pageCtrl.activePage + 1;
            }
        };

        pageCtrl.prevPage = function(){
            if (pageCtrl.activePage > 1) {
                pageCtrl.activePage = pageCtrl.activePage - 1;
            }
        };
    }]);

    app.controller('FormController', function(){
        var formCtrl = this;
    });

})();
