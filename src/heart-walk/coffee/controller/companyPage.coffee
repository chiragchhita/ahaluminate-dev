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
      
      $defaultCompanyHierarchy = angular.element '.js--default-company-hierarchy'
      $childCompanyAmounts = $defaultCompanyHierarchy.find('.trr-td p.righted')
      totalCompanyAmountRaised = 0
      angular.forEach $childCompanyAmounts, (childCompanyAmount) ->
        amountRaised = angular.element(childCompanyAmount).text()
        if amountRaised
          amountRaised = amountRaised.replace('$', '').replace(/,/g, '')
          amountRaised = Number(amountRaised) * 100
          totalCompanyAmountRaised += amountRaised
      
      $defaultCompanySummary = angular.element '.js--default-company-summary'
      companyGiftCount = $defaultCompanySummary.find('.company-tally-container--gift-count .company-tally-ammount').text()
      if companyGiftCount is ''
        companyGiftCount = '0'
      $scope.companyProgress = 
        numDonations: companyGiftCount
      
      setCompanyFundraisingProgress = (amountRaised, goal) ->
        $scope.companyProgress.amountRaised = amountRaised or 0
        $scope.companyProgress.amountRaised = Number $scope.companyProgress.amountRaised
        $scope.companyProgress.amountRaisedFormatted = $filter('currency')($scope.companyProgress.amountRaised / 100, '$', 0)
        $scope.companyProgress.goal = goal or 0
        $scope.companyProgress.goal = Number $scope.companyProgress.goal
        $scope.companyProgress.goalFormatted = $filter('currency')($scope.companyProgress.goal / 100, '$', 0)
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
      TeamraiserCompanyService.getCompanies 'company_id=' + $scope.companyId, 
        error: ->
          setCompanyFundraisingProgress()
        success: (response) ->
          companyInfo = response.getCompaniesResponse?.company
          if not companyInfo
            setCompanyFundraisingProgress()
          else
            setCompanyFundraisingProgress totalCompanyAmountRaised, companyInfo.goal
      
      $childCompanyLinks = $defaultCompanyHierarchy.find('.trr-td a')
      $scope.childCompanies = []
      angular.forEach $childCompanyLinks, (childCompanyLink) ->
        childCompanyUrl = angular.element(childCompanyLink).attr('href')
        childCompanyName = angular.element(childCompanyLink).text()
        if childCompanyUrl.indexOf('company_id=') isnt -1
          $scope.childCompanies.push 
            id: childCompanyUrl.split('company_id=')[1].split('&')[0]
            name: childCompanyName
      numCompanies = $scope.childCompanies.length + 1
      
      $scope.companyTeamSearch = 
        team_name: ''
      $scope.companyTeams = 
        isOpen: true
        page: 1
      setCompanyTeams = (teams, totalNumber) ->
        $scope.companyTeams.teams = teams or []
        totalNumber = totalNumber or 0
        $scope.companyTeams.totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()
      $scope.childCompanyTeams = 
        companies: []
      addChildCompanyTeams = (companyIndex, companyId, companyName, teams, totalNumber) ->
        pageNumber = $scope.childCompanyTeams.companies[companyIndex]?.page or 0
        $scope.childCompanyTeams.companies[companyIndex] = 
          isOpen: true
          page: pageNumber
          companyIndex: companyIndex
          companyId: companyId or ''
          companyName: companyName or ''
          teams: teams or []
        totalNumber = totalNumber or 0
        $scope.childCompanyTeams.companies[companyIndex].totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()
      setCompanyNumTeams = (numTeams) ->
        if not $scope.companyProgress.numTeams
          $scope.companyProgress.numTeams = numTeams or 0
        if not $scope.$$phase
          $scope.$apply()
      $scope.getCompanyTeamLists = ->
        numCompaniesTeamRequestComplete = 0
        numTeams = 0
        $scope.getCompanyTeams = ->
          # TODO: scroll to top of list
          pageNumber = $scope.companyTeams.page - 1
          TeamraiserTeamService.getTeams 'team_company_id=' + $scope.companyId + '&team_name=' + $scope.companyTeamSearch.team_name + '&list_sort_column=total&list_ascending=false&list_page_size=5&list_page_offset=' + pageNumber, 
            error: ->
              setCompanyTeams()
              numCompaniesTeamRequestComplete++
              if numCompaniesTeamRequestComplete is numCompanies
                setCompanyNumTeams numTeams
            success: (response) ->
              setCompanyTeams()
              companyTeams = response.getTeamSearchByInfoResponse?.team
              if companyTeams
                companyTeams = [companyTeams] if not angular.isArray companyTeams
                angular.forEach companyTeams, (companyTeam) ->
                  companyTeam.amountRaised = Number companyTeam.amountRaised
                  companyTeam.amountRaisedFormatted = $filter('currency')(companyTeam.amountRaised / 100, '$', 0)
                  joinTeamURL = companyTeam.joinTeamURL
                  if joinTeamURL
                    companyTeam.joinTeamURL = joinTeamURL.split('/site/')[1]
                totalNumberTeams = response.getTeamSearchByInfoResponse.totalNumberResults
                setCompanyTeams companyTeams, totalNumberTeams
                numTeams += Number totalNumberTeams
              numCompaniesTeamRequestComplete++
              if numCompaniesTeamRequestComplete is numCompanies
                setCompanyNumTeams numTeams
        $scope.getCompanyTeams()
        $scope.getChildCompanyTeams = (childCompanyIndex) ->
          # TODO: scroll to top of list
          childCompany = $scope.childCompanies[childCompanyIndex]
          childCompanyId = childCompany.id
          childCompanyName = childCompany.name
          pageNumber = $scope.childCompanyTeams.companies[childCompanyIndex]?.page
          if not pageNumber
            pageNumber = 0
          else
            pageNumber--
          TeamraiserTeamService.getTeams 'team_company_id=' + childCompanyId + '&team_name=' + $scope.companyTeamSearch.team_name + '&list_sort_column=total&list_ascending=false&list_page_size=5&list_page_offset=' + pageNumber, 
            error: ->
              addChildCompanyTeams childCompanyIndex, childCompanyId, childCompanyName
              numCompaniesTeamRequestComplete++
              if numCompaniesTeamRequestComplete is numCompanies
                setCompanyNumTeams numTeams
            success: (response) ->
              companyTeams = response.getTeamSearchByInfoResponse?.team
              if not companyTeams
                addChildCompanyTeams childCompanyIndex, childCompanyId, childCompanyName
              else
                companyTeams = [companyTeams] if not angular.isArray companyTeams
                angular.forEach companyTeams, (companyTeam) ->
                  companyTeam.amountRaised = Number companyTeam.amountRaised
                  companyTeam.amountRaisedFormatted = $filter('currency')(companyTeam.amountRaised / 100, '$', 0)
                  joinTeamURL = companyTeam.joinTeamURL
                  if joinTeamURL
                    companyTeam.joinTeamURL = joinTeamURL.split('/site/')[1]
                totalNumberTeams = response.getTeamSearchByInfoResponse.totalNumberResults
                addChildCompanyTeams childCompanyIndex, childCompanyId, childCompanyName, companyTeams, totalNumberTeams
                numTeams += Number totalNumberTeams
              numCompaniesTeamRequestComplete++
              if numCompaniesTeamRequestComplete is numCompanies
                setCompanyNumTeams numTeams
        angular.forEach $scope.childCompanies, (childCompany, childCompanyIndex) ->
          $scope.getChildCompanyTeams childCompanyIndex
      $scope.getCompanyTeamLists()
      
      $scope.searchCompanyTeams = (companyTeamSearch) ->
        $scope.companyTeamSearch.team_name = companyTeamSearch?.team_name or ''
        $scope.companyTeams.isOpen = true
        $scope.companyTeams.page = 1
        angular.forEach $scope.childCompanyTeams.companies, (company, companyIndex) ->
          $scope.childCompanyTeams.companies[companyIndex].isOpen = true
          $scope.childCompanyTeams.companies[companyIndex].page = 1
        $scope.getCompanyTeamLists()
      
      $scope.companyParticipantSearch = 
        participant_name: ''
      $scope.companyParticipants = 
        isOpen: true
        page: 1
      setCompanyParticipants = (participants, totalNumber) ->
        $scope.companyParticipants.participants = participants or []
        totalNumber = totalNumber or 0
        $scope.companyParticipants.totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()
      $scope.childCompanyParticipants = 
        companies: []
      addChildCompanyParticipants = (companyIndex, companyId, companyName, participants, totalNumber) ->
        pageNumber = $scope.childCompanyParticipants.companies[companyIndex]?.page or 0
        $scope.childCompanyParticipants.companies[companyIndex] = 
          isOpen: true
          page: pageNumber
          companyIndex: companyIndex
          companyId: companyId or ''
          companyName: companyName or ''
          participants: participants or []
        totalNumber = totalNumber or 0
        $scope.childCompanyParticipants.companies[companyIndex].totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()
      setCompanyNumParticipants = (numParticipants) ->
        $scope.companyProgress.numParticipants = numParticipants or 0
        if not $scope.$$phase
          $scope.$apply()
      $scope.getCompanyParticipantLists = ->
        numCompaniesParticipantRequestComplete = 0
        numParticipants = 0
        $scope.getCompanyParticipants = ->
          # TODO: scroll to top of list
          firstName = $scope.companyParticipantSearch.participant_name
          lastName = ''
          if $scope.companyParticipantSearch.participant_name.indexOf(' ') isnt -1
            firstName = $scope.companyParticipantSearch.participant_name.split(' ')[0]
            lastName = $scope.companyParticipantSearch.participant_name.split(' ')[1]
          pageNumber = $scope.companyParticipants.page - 1
          TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%%%') + '&first_name=' + firstName + '&last_name=' + lastName + '&list_filter_column=team.company_id&list_filter_text=' + $scope.companyId + '&list_sort_column=total&list_ascending=false&list_page_size=5&list_page_offset=' + pageNumber, 
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
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$', 0)
                    donationUrl = participant.donationUrl
                    if donationUrl
                      participant.donationUrl = donationUrl.split('/site/')[1]
                    companyParticipants.push participant
                totalNumberParticipants = response.getParticipantsResponse.totalNumberResults
                setCompanyParticipants companyParticipants, totalNumberParticipants
                numParticipants += Number totalNumberParticipants
              numCompaniesParticipantRequestComplete++
              if numCompaniesParticipantRequestComplete is numCompanies
                setCompanyNumParticipants numParticipants
        $scope.getCompanyParticipants()
        $scope.getChildCompanyParticipants = (childCompanyIndex) ->
          # TODO: scroll to top of list
          childCompany = $scope.childCompanies[childCompanyIndex]
          childCompanyId = childCompany.id
          childCompanyName = childCompany.name
          firstName = $scope.companyParticipantSearch.participant_name
          lastName = ''
          if $scope.companyParticipantSearch.participant_name.indexOf(' ') isnt -1
            firstName = $scope.companyParticipantSearch.participant_name.split(' ')[0]
            lastName = $scope.companyParticipantSearch.participant_name.split(' ')[1]
          pageNumber = $scope.childCompanyParticipants.companies[childCompanyIndex]?.page
          if not pageNumber
            pageNumber = 0
          else
            pageNumber--
          TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%%%') + '&first_name=' + firstName + '&last_name=' + lastName + '&list_filter_column=team.company_id&list_filter_text=' + childCompanyId + '&list_sort_column=total&list_ascending=false&list_page_size=5&list_page_offset=' + pageNumber, 
            error: ->
              addChildCompanyParticipants childCompanyIndex, childCompanyId, childCompanyName
              numCompaniesParticipantRequestComplete++
              if numCompaniesParticipantRequestComplete is numCompanies
                setCompanyNumParticipants numParticipants
            success: (response) ->
              participants = response.getParticipantsResponse?.participant
              if not participants
                addChildCompanyParticipants childCompanyIndex, childCompanyId, childCompanyName
              else
                participants = [participants] if not angular.isArray participants
                companyParticipants = []
                angular.forEach participants, (participant) ->
                  if participant.name?.first
                    participant.amountRaised = Number participant.amountRaised
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$', 0)
                    donationUrl = participant.donationUrl
                    if donationUrl
                      participant.donationUrl = donationUrl.split('/site/')[1]
                    companyParticipants.push participant
                totalNumberParticipants = response.getParticipantsResponse.totalNumberResults
                addChildCompanyParticipants childCompanyIndex, childCompanyId, childCompanyName, companyParticipants, totalNumberParticipants
                numParticipants += Number totalNumberParticipants
              numCompaniesParticipantRequestComplete++
              if numCompaniesParticipantRequestComplete is numCompanies
                setCompanyNumParticipants numParticipants
        angular.forEach $scope.childCompanies, (childCompany, childCompanyIndex) ->
          $scope.getChildCompanyParticipants childCompanyIndex
      $scope.getCompanyParticipantLists()
      
      $scope.searchCompanyParticipants = (companyParticipantSearch) ->
        $scope.companyParticipantSearch.participant_name = companyParticipantSearch?.participant_name or ''
        $scope.companyParticipants.isOpen = true
        $scope.companyParticipants.page = 1
        angular.forEach $scope.childCompanyParticipants.companies, (company, companyIndex) ->
          $scope.childCompanyParticipants.companies[companyIndex].isOpen = true
          $scope.childCompanyParticipants.companies[companyIndex].page = 1
        $scope.getCompanyParticipantLists()
  ]