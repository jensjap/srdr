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
            if (pageCtrl.activePage === 10) {
                document.getElementById("next").className = "fade";
            } else {
                document.getElementById("next").className = "";
            }
        });

        pageCtrl.nextPage = function(){
            consentSelect = document.getElementById("daa_consent_agree");
            if (pageCtrl.activePage === 8) {
                if (consentSelect.value === "false") {
                    return;
                }
            }
            if (pageCtrl.activePage < 10) {
                pageCtrl.activePage = pageCtrl.activePage + 1;
            }
        };

        pageCtrl.prevPage = function(){
            if (pageCtrl.activePage > 1) {
                pageCtrl.activePage = pageCtrl.activePage - 1;
            }
        };
    }]);

})();
