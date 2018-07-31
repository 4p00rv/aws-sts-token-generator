require 'json'

MFA_DEVICE_TO_PROFILE_MAP = {
  'production'=> '',
  'default'=> ''
}
MFA_DEFAULT_PROFILE_NAME = 'mfa'
CREDENTIALS_FILE_PATH = File.expand_path('~/.aws/credentials')

def get_credentials
  file = File.new(CREDENTIALS_FILE_PATH, 'r')
  is_default_profile = false
  content = ''
  while (line = file.gets)
    if line =~ /\[[\w\d]+\]/
      is_default_profile = line =~ /\[#{MFA_DEFAULT_PROFILE_NAME}\]/ ? true : false
    end
    next if is_default_profile
    content += line
  end
  return content
end

def update_credentials(content)
  File.write(CREDENTIALS_FILE_PATH, content)
end

def usage
  puts %{
Usage: #{__FILE__} --token 123456

Options:

--profile: 'Specify aws profile to be used to for aws cli. Please add the corresponding mfa device id to MFA_DEVICE_TO_PROFILE_MAP.'

--duration: 'Duration (in seconds) for which the token is valid.'
  }
end

def get_args
  allowed_arguments = ['profile','duration','token']
  args_map = {
    'profile' => 'default',
    'duration' => 900
  }
  ARGV.each_index do |i|
    arg = ARGV[i].dup
    arg.sub! '--', ''
    args_map[arg] = ARGV[i+1] if allowed_arguments.include? arg
  end
  unless args_map.key? 'token'
    usage()
    exit
  end
  return args_map
end

def main
  args = get_args()
  cmd = "aws sts get-session-token --duration-seconds #{args['duration']} --token-code #{args['token']} --profile #{args['profile']} --serial-number #{MFA_DEVICE_TO_PROFILE_MAP[args['profile']]}"
  stdout = %x[#{cmd}]
  puts stdout
  stdout.chomp!
  res = JSON.parse(stdout)['Credentials']
  content = get_credentials()
  content += %{[#{MFA_DEFAULT_PROFILE_NAME}]
aws_access_key_id=#{res['AccessKeyId']}
aws_secret_access_key=#{res['SecretAccessKey']}
aws_session_token=#{res['SessionToken']}
}
  update_credentials(content)
end

main()

