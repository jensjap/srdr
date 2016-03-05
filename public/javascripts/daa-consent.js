(function(){
    // Some AngularJs magic.
    var app = angular.module('daaConsent', []);

    app.controller('PageController', ["$scope", function($scope){
        var pageCtrl = this;
        var targetPage = document.getElementById('page-header').getAttribute('data-targetpage');
        var consentSelect;
        var backBtn   = document.getElementById("back"),
            nextBtn   = document.getElementById("next");

        if (targetPage === "8") {
            pageCtrl.activePage = 8;
        } else {
            pageCtrl.activePage = 1;
        }

        $scope.$watch('pageCtrl.activePage', function(newValue, oldValue){
            consentSelect = document.getElementById("daa_consent_agree");
            // We want to see the back button on every page except page 1.
            if (pageCtrl.activePage === 1) {
                backBtn.className = backBtn.className + " hidden";
            } else {
                backBtn.className = backBtn.className.replace(" hidden", "");
            }
            // We want to see the next button on every page except page 8.
            if (pageCtrl.activePage === 8) {
                nextBtn.className = nextBtn.className + " hidden";
            } else {
                nextBtn.className = nextBtn.className.replace(" hidden", "");
            }
        });

        pageCtrl.nextPage = function(){
            if (pageCtrl.activePage < 8) {
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

