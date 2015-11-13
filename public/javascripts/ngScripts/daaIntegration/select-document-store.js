(function(){
    var app = angular.module('selectDocument', []);

    app.directive('selectDocument', ['$http', function($http){
        return {
            // Create an element directive.
            restrict: 'E',
            // Define template location.
            templateUrl: "/ngTemplates/daaIntegration/select-document-store.html",
            // Controller logic here.
            controller: function(){
                var sdCtrl = this;
                var remoteHost = 'http://api.daa-dev.com:3030';

                // Models are bound to select elements in the template.
                sdCtrl.documentStores = [ ];
                sdCtrl.documents = [ ];

                // Set up the document stores index endpoint.
                var documentStoresIndexUrl = remoteHost + '/v1/document_stores';
                $http.get(documentStoresIndexUrl)
                    .then(function successCallback(response){
                        sdCtrl.documentStores = response.data;
                    }, function errorCallback(poopy){
                        console.log("(" + documentStoresIndexUrl + ") " +
                                    poopy.status + ": " + poopy.statusText);
                    });

                // Once the document store is chosen we fetch the documents.
                sdCtrl.documentStoreChange = function(){
                    // Set up the documents index endpoint.
                    var documentsIndexUrl = remoteHost + '/v1/document_stores/' +
                                            sdCtrl.documentStoreSelect + '/documents';
                    $http.get(documentsIndexUrl)
                        .then(function successCallback(response){
                            sdCtrl.documents = response.data;
                        }, function errorCallback(poopy){
                            console.log("(" + documentsIndexUrl + ") " +
                                        poopy.status + ": " + poopy.statusText);
                        });
                };

                sdCtrl.documentChange = function(){
                    // Set up html endpoint.
                    var documentHtmlUrl = remoteHost + '/v1/documents/' +
                                          sdCtrl.documentSelect + '/html';
                    $http.get(documentHtmlUrl)
                        .then(function successCallback(response){
                            // angular.element is an alias for jQuery function.
                            angular.element("#split-right")[0]
                                .innerHTML = response.data;
                            // Set up the drop zones in the PDF.
                            angular.element("div#page-container div.t")
                                .addClass('drop-zone');
                        }, function errorCallback(poopy){
                            console.log("(" + documentHtmlUrl + ") " +
                                        poopy.status + ": " + poopy.statusText);
                        });
                };
            },
            controllerAs: 'sdCtrl'
        };
    }]);

})();
