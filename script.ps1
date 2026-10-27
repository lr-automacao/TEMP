<#
=======================================================
 SCRIPT PARA INICIALIZACAO DO DOCKER E GERACAO DE LOGS
=======================================================
#>

# =================== CONFIGURACOES ===================

# DECLARACAO DAS VARIAVEIS
$VersaoScript = "3.5.6"
$URLScriptGIT = "https://raw.githubusercontent.com/lr-automacao/TEMP/main/script.ps1" 
$ArqScriptAtual = "C:\Users\Administrador\Desktop\TESTE\script.ps1"
$ArqScriptTemp = "$ArqScriptAtual.download"
$ArqScriptBackup = "$ArqScriptAtual.backup"

# PUBLICA A VERSAO DO SCRIPT NO LOG
Write-Host "..:: Script de inicialização do ambiente Docker | Versão $VersaoScript ::.."

# ==================== ATUALIZACAO ====================

# VERIFICA ATUALIZACOES DO SCRIPT
Write-Host "[PROCESSANDO] Verificando se há uma nova versão do script..."
Start-Sleep -Seconds 2

try {
	
	# OBTEM O CONTEUDO DO SCRIPT NO REPOSITORIO DO GITHUB
	Write-Host  "[AGUARDANDO] Acessando o repositório do GitHub para obter o script..."
    $RetornoGit = Invoke-WebRequest -Uri $URLScriptGIT -UseBasicParsing -ErrorAction Stop
    $ScriptGit = $RetornoGit.Content
	
	# CAPTURA A VERSAO DO SCRIPT REMOTO
	$VersaoGit = [regex]::Match($ScriptGit, '\$VersaoScript\s*=\s*"([^"]+)"').Groups[1].Value
		
	# VALIDA SE O CONTEUDO FOI OBTIDO
	if ([string]::IsNullOrWhiteSpace($VersaoGit)) {
		Write-Host  "[ERRO] Não foi possível validar a existência de atualizações, pois a consulta retornou um conteúdo vazio."
		exit 1
	}
			
	# COMPARA AS VERSOES
	$VersaoLocal = [version]$VersaoScript
    $VersaoRemota = [version]$VersaoGit

	if ($VersaoLocal -lt $VersaoRemota) {
		Write-Host "Atualização necessária. Versao Local: $VersaoLocal Versao Git: $VersaoRemota"
		
		# BAIXA A NOVA VERSAO DO SCRIPT EM ARQUIVO TEMPORARIO
        [System.IO.File]::WriteAllText(
            $ArqScriptTemp,
            $ScriptGit,
            [System.Text.UTF8Encoding]::new($true)
        )
		
		# VERIFICA O ARQUIVO BAIXADO
		if (Test-Path -LiteralPath $ArqScriptTemp -PathType Leaf) {
			Write-Host "Arquivo encontrado."
			
			Start-Sleep -Seconds 30
			
			#CAPTURA O CONTEUDO DO ARQUIVO TEMPORARIO
			$ConteudoScriptTemp = [System.IO.File]::ReadAllText($ArqScriptTemp)
						
			# COMPARA O CONTEUDO DO ARQUIVO TEMPORARIO COM O CONTEUDO DO GIT
			if ($ConteudoScriptTemp -eq $ScriptGit) {
				Write-Host "[SUCESSO] Arquivo baixado e validado. Versão: $VersaoGit"
				
				# CRIA COPIA DO SCRIPT ATUAL
				Copy-Item -LiteralPath $ArqScriptAtual -Destination $ArqScriptBackup -Force -ErrorAction Stop
				
				# CRIA COPIA DO SCRIPT ATUAL
				Copy-Item -LiteralPath $ArqScriptTemp -Destination $ArqScriptAtual -Force -ErrorAction Stop
				
			} else {
			
				Write-Host "[ERRO] O conteúdo do arquivo é diferente do conteúdo do GitHub."
				Remove-Item -LiteralPath $ArqScriptTemp -Force
			}
						
		} else {
			Write-Host "Arquivo não encontrado."
		}

    # Coloque aqui o código de atualização
	}
	else {
		Write-Host "A versão já está atualizada. Versao Local: $VersaoLocal Versao Git: $VersaoRemota"
	}
	
} catch {
	Write-Host  "[ERRO] Não foi possível verificar se há atualizações."
	exit 0
	
}
