Facter.add("username") do
  confine :operatingsystem => 'windows'
  setcode do
    if Facter.value(:kernelmajversion) == "10.0"
      # W10
      # TODO: "Ativo" only works for Windows-pt_BR. In Windows-en, for example, it should be "active".
      resultado = Facter::Util::Resolution.exec("query user")
      resultado = resultado.split("\n").select {|line| /Ativo/.match(line)}
      username_line = resultado[0]
      if username_line.nil?
        retorno = nil
      else
        retorno = username_line.match(/\W?([A-Za-z0-9]+)/)[1]
      end
    else
      # WXP e W7
      resultado = Facter::Util::Resolution.exec("wmic computersystem get username")
      resultado.gsub! "\r","\n"
      resultado.gsub! /\n+/,"\n"
      # wmic computersystem get username returns a string similar to
      # UserName
      # REDE\m23337
      username_line = resultado.split("\n")[1]
      if  username_line.nil?
        retorno = nil
      else
        retorno = username_line.split("\\")[1].strip
      end
    end
    retorno.nil? ? "unknown" : retorno
  end
end