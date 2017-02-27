module API
  class PersonalAccessTokens < Grape::API
    include PaginationParams

    before do
      authenticate!
      @finder = PersonalAccessTokensFinder.new(user: current_user, impersonation: false)
    end

    resource :personal_access_tokens do
      desc 'Retrieve personal access tokens' do
        detail 'This feature was introduced in GitLab 9.0'
        success Entities::PersonalAccessToken
      end
      params do
        optional :state, type: String, default: 'all', values: %w[all active inactive], desc: 'Filters (all|active|inactive) personal_access_tokens'
        use :pagination
      end
      get do
        @finder.params.merge!(declared_params(include_missing: false))
        present paginate(@finder.execute), with: Entities::PersonalAccessToken
      end

      desc 'Retrieve personal access token' do
        detail 'This feature was introduced in GitLab 9.0'
        success Entities::PersonalAccessToken
      end
      params do
        requires :personal_access_token_id, type: Integer, desc: 'The ID of the personal access token'
      end
      get ':personal_access_token_id' do
        personal_access_token = @finder.execute(id: declared_params[:personal_access_token_id])
        not_found!('Personal Access Token') unless personal_access_token

        present personal_access_token, with: Entities::PersonalAccessToken
      end

      desc 'Create a personal access token' do
        detail 'This feature was introduced in GitLab 9.0'
        success Entities::PersonalAccessTokenWithToken
      end
      params do
        requires :name, type: String, desc: 'The name of the personal access token'
        optional :expires_at, type: Date, desc: 'The expiration date in the format YEAR-MONTH-DAY of the personal access token'
        optional :scopes, type: Array, desc: 'The array of scopes of the personal access token'
      end
      post do
        personal_access_token = @finder.execute.build(declared_params(include_missing: false))

        if personal_access_token.save
          present personal_access_token, with: Entities::PersonalAccessTokenWithToken
        else
          render_validation_error!(personal_access_token)
        end
      end

      desc 'Revoke a personal access token' do
        detail 'This feature was introduced in GitLab 9.0'
      end
      params do
        requires :personal_access_token_id, type: Integer, desc: 'The ID of the personal access token'
      end
      delete ':personal_access_token_id' do
        personal_access_token = @finder.execute(id: declared_params[:personal_access_token_id])
        not_found!('Personal Access Token') unless personal_access_token

        personal_access_token.revoke!
      end
    end
  end
end
