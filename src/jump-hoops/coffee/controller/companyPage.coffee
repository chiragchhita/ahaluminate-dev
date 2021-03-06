angular.module 'ahaLuminateControllers'
  .controller 'CompanyPageCtrl', [
    '$scope'
    '$location'
    '$filter'
    '$timeout'
    'TeamraiserCompanyService'
    'TeamraiserTeamService'
    'TeamraiserParticipantService'
    ($scope, $location, $filter, $timeout, TeamraiserCompanyService, TeamraiserTeamService, TeamraiserParticipantService) ->
      $scope.companyId = $location.absUrl().split('company_id=')[1].split('&')[0]
      $scope.companyProgress = []
      $scope.companyName = ''
      $scope.companyEventDate = ''
      $scope.totalTeams = ''

      setCompanyFundraisingProgress = (amountRaised, goal) ->
        $scope.companyProgress.amountRaised = amountRaised
        $scope.companyProgress.amountRaised = Number $scope.companyProgress.amountRaised
        $scope.companyProgress.amountRaisedFormatted = $filter('currency')($scope.companyProgress.amountRaised / 100, '$').replace '.00', ''
        $scope.companyProgress.goal = goal or 0
        $scope.companyProgress.goal = Number $scope.companyProgress.goal
        $scope.companyProgress.goalFormatted = $filter('currency')($scope.companyProgress.goal / 100, '$').replace '.00', ''
        $scope.companyProgress.percent = 2
        $timeout ->
          percent = $scope.companyProgress.percent
          if $scope.companyProgress.goal isnt 0
            percent = Math.ceil(($scope.companyProgress.amountRaised / $scope.companyProgress.goal) * 100)
          if percent < 2
            percent = 2
          if percent > 98
            percent = 98
          $scope.companyProgress.percent = percent
          if not $scope.$$phase
            $scope.$apply()
        , 500
        if not $scope.$$phase
          $scope.$apply()

      getCompanyTotals = ->
        TeamraiserCompanyService.getCompanies 'company_id=' + $scope.companyId, 
            success: (response) ->
              console.log response
              $scope.totalTeams = response.getCompaniesResponse.company.teamCount
              amountRaised = response.getCompaniesResponse.company.amountRaised
              goal = response.getCompaniesResponse.company.goal
              name = response.getCompaniesResponse.company.companyName
              coordinatorId = response.getCompaniesResponse.company.coordinatorId
              $scope.companyName = name
              setCompanyFundraisingProgress amountRaised, goal

              TeamraiserParticipantService.getParticipants 'first_name=' + encodeURIComponent('%%%') + '&last_name=' + encodeURIComponent('%%%') + '&list_filter_column=reg.cons_id&list_filter_text=' + coordinatorId,
                error: (response) ->
                  console.log 'error'
                  console.log response
                success: (response) ->
                  console.log 'sucess'
                  console.log response
                  #$scope.companyEventDate


              console.log 'test='+$scope.companyName

      getCompanyTotals()



      $scope.companyTeams = []
      setCompanyTeams = (teams, totalNumber) ->
        $scope.companyTeams.teams = teams or []
        totalNumber = totalNumber or 0
        $scope.companyTeams.totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()

      getCompanyTeams = ->
        TeamraiserTeamService.getTeams 'team_company_id=' + $scope.companyId,
          success: (response) ->
            setCompanyTeams()
            companyTeams = response.getTeamSearchByInfoResponse.team
            if companyTeams
              companyTeams = [companyTeams] if not angular.isArray companyTeams          
              angular.forEach companyTeams, (companyTeam) ->
                companyTeam.amountRaised = Number companyTeam.amountRaised
                companyTeam.amountRaisedFormatted = $filter('currency')(companyTeam.amountRaised / 100, '$').replace '.00', ''
                joinTeamURL = companyTeam.joinTeamURL
                if joinTeamURL
                  companyTeam.joinTeamURL = joinTeamURL.split('/site/')[1]
              totalNumberTeams = response.getTeamSearchByInfoResponse.totalNumberResults
              setCompanyTeams companyTeams, totalNumberTeams

      getCompanyTeams()


      $scope.companyParticipants = []
      setCompanyParticipants = (participants, totalNumber) ->
        $scope.companyParticipants.participants = participants or []
        totalNumber = totalNumber or 0
        $scope.companyParticipants.totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()

      getCompanyParticipants = ->
        TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%%%') + '&first_name=' + encodeURIComponent('%%%') + '&last_name=' + encodeURIComponent('%%%') + '&list_filter_column=team.company_id&list_filter_text=' + $scope.companyId + '&list_sort_column=total&list_ascending=false', 
            error: ->
              setCompanyParticipants()
              numCompaniesParticipantRequestComplete++
              if numCompaniesParticipantRequestComplete is numCompanies
                setCompanyNumParticipants numParticipants
            success: (response) ->
              setCompanyParticipants()
              participants = response.getParticipantsResponse?.participant
              if participants
                participants = [participants] if not angular.isArray participants
                companyParticipants = []
                angular.forEach participants, (participant) ->
                  if participant.name?.first
                    participant.amountRaised = Number participant.amountRaised
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$').replace '.00', ''
                    donationUrl = participant.donationUrl
                    if donationUrl
                      participant.donationUrl = donationUrl.split('/site/')[1]
                    companyParticipants.push participant
                totalNumberParticipants = response.getParticipantsResponse.totalNumberResults
                setCompanyParticipants companyParticipants, totalNumberParticipants
      getCompanyParticipants()




  ]