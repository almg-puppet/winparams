Facter.add("username") do
  confine :operatingsystem => 'windows'
  setcode do
    # TODO: "Ativo" only works for Windows-pt_BR. In Windows-en, for example, it should be "active".
    resultado = Facter::Util::Resolution.exec("query user")
    resultado = resultado.split("\n").select {|line| /Ativo/.match(line)}
    username_line = resultado[0]
    if username_line.nil?
      retorno = nil
    else
      retorno = username_line.match(/\W?([A-Za-z0-9]+)/)[1]
    end
    retorno == "" || retorno.nil? ? "unknown" : retorno
  end
end