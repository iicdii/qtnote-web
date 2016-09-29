Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, "305001449857-29ep15ql0n5fms3tgef7na3tar6bcqdl.apps.googleusercontent.com", "g6ZEa7MzX84OIJhJZaZtGha1"
    provider :facebook, "191081754661940", "a0e6957fd29d859b587c720c1cc24146", scope: 'email', info_fields: 'email,name'
    on_failure { |env| AuthenticationsController.action(:failure).call(env) }
end