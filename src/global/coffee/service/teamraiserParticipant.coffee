angular.module 'ahaLuminateApp'
  .factory 'TeamraiserParticipantService', [
    'LuminateRESTService'
    (LuminateRESTService) ->
      getParticipants: (requestData, callback) ->
        dataString = 'method=getParticipants'
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, false, true, callback

      
  ]