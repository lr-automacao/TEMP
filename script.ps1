<#
=======================================================
 SCRIPT PARA INICIALIZACAO DO DOCKER E GERACAO DE LOGS
=======================================================
#>

# =================== CONFIGURACOES ===================

# DECLARACAO DAS VARIAVEIS
$VersaoScript = "5.5.7"
$URLScriptGIT = "https://raw.githubusercontent.com/lr-automacao/TEMP/main/script.ps1" 
$CaminhoScriptAtual = "C:\Users\Administrador\Desktop\TESTE\script.ps1"
$CaminhoScriptDownload = "$CaminhoScriptAtual.download"
$CaminhoScriptBackup = "$CaminhoScriptAtual.backup"

# PUBLICA A VERSAO DO SCRIPT NO LOG
Write-Host "..:: Script de inicialização do ambiente Docker | Versão $VersaoScript ::.."

# ==================== ATUALIZACAO ====================

# VERIFICA ATUALIZACOES DO SCRIPT
Write-Host "[PROCESSANDO] Verificando se há atualizações disponíveis para o script..."
Start-Sleep -Seconds 2

try {
	
	# COLETA O SCRIPT PUBLICADO NO GITHUB
	Write-Host  "[AGUARDANDO] Consultando a versão publicada no repositório do GitHub..."
	Start-Sleep -Seconds 2
	
    $RetornoGit = Invoke-WebRequest -Uri $URLScriptGIT -UseBasicParsing -ErrorAction Stop
    $ConteudoScriptGit = $RetornoGit.Content
	
	# IDENTIFICA A VERSAO PUBLICADA NO GITHUB
	$VersaoGit = [regex]::Match($ConteudoScriptGit, '\$VersaoScript\s*=\s*"([^"]+)"').Groups[1].Value
		
	# VALIDA A VERSAO COLETADA
	if ([string]::IsNullOrWhiteSpace($VersaoGit)) {
		Write-Host  "[ERRO] Não foi possível identificar a versão publicada no repositório do GitHub."
		exit 1
	}
			
	# COMPARA AS VERSOES
	$VersaoLocal = [version]$VersaoScript
    $VersaoRemota = [version]$VersaoGit

	if ($VersaoLocal -lt $VersaoRemota) {
		
		Write-Host "[AVISO] Uma versão mais recente foi encontrada.	Versão em execução: $VersaoLocal | Versão disponível: $VersaoRemota."
		Start-Sleep -Seconds 2
		Write-Host "[AGUARDANDO] Iniciando o processo de atualização..."
		
		# SALVA O SCRIPT REMOTO EM UM ARQUIVO TEMPORARIO
		Write-Host "[INFO] Iniciando o download da versão mais recente do script..."
		[System.IO.File]::WriteAllText(
            $CaminhoScriptDownload,
            $ConteudoScriptGit,
            [System.Text.UTF8Encoding]::new($true)
        )
		
		# VALIDA O ARQUIVO BAIXADO
		if (Test-Path -LiteralPath $CaminhoScriptDownload -PathType Leaf) {
			
			Write-Host "[SUCESSO] O download do script concluído com êxito."
			Start-Sleep -Seconds 2
            Write-Host "[INFO] Iniciando a verificação de integridade do arquivo baixado..."
			
			#CAPTURA O CONTEUDO DO ARQUIVO BAIXADO
			$ConteudoScriptDownload = [System.IO.File]::ReadAllText($CaminhoScriptDownload)
						
			# COMPARA O CONTEUDO DO ARQUIVO BAIXADO COM O CONTEUDO DO GIT
			if ($ConteudoScriptDownload -ceq $ConteudoScriptGit) {
								
				Write-Host "[SUCESSO] A verificação de integridade do arquivo foi concluída com êxito."
				Start-Sleep -Seconds 2
                Write-Host "[INFO] Iniciando o processo de cópia de segurança do script atual..."
								
				# FAZ BACKUP DO SCRIPT ATUAL
				Copy-Item -LiteralPath $CaminhoScriptAtual -Destination $CaminhoScriptBackup -Force -ErrorAction Stop
				
					# VALIDA O ARQUIVO DE BACKUP
					if (Test-Path -LiteralPath $CaminhoScriptBackup -PathType Leaf) {			
				
						Write-Host "[SUCESSO] A cópia de segurança foi criada com êxito."
						Start-Sleep -Seconds 2
						
						# CAPTURA O CONTEUDO DO ARQUIVO DE BACKUP
						$ConteudoScriptBackup = [System.IO.File]::ReadAllText($CaminhoScriptBackup)
						
						# CAPTURA O CONTEUDO DO ARQUIVO ATUAL
						$ConteudoScriptAtual = [System.IO.File]::ReadAllText($CaminhoScriptAtual)
						
						Write-Host "[INFO] Analisando os dados do backup gerado..."
						Start-Sleep -Seconds 2
						
						# COMPARA O CONTEUDO DO BACKUP COM O CONTEUDO ATUAL
						if ($ConteudoScriptBackup -ceq $ConteudoScriptAtual) {
							
							Write-Host "[SUCESSO] O backup foi validado; nenhuma inconsistência encontrada!"
							Start-Sleep -Seconds 2
							Write-Host "[INFO] Atualizando o arquivo do script para a versão mais recente..."
				
							# SUBSTITUI O SCRIPT ATUAL PELO BAIXADO
							Copy-Item -LiteralPath $CaminhoScriptDownload -Destination $CaminhoScriptAtual -Force -ErrorAction Stop
							
							# CAPTURA O CONTEUDO DO ARQUIVO ATUAL
							$ConteudoScriptAtual = [System.IO.File]::ReadAllText($CaminhoScriptAtual)
							
							if ($ConteudoScriptAtual -ceq $ConteudoScriptGit) {
								
								Write-Host "[SUCESSO] Atualização do script finalizada a nova versão foi implantada no ambiente."
								Start-Sleep -Seconds 2
								Write-Host "[INFO] Iniciando a exclusão dos arquivos temporários..."
								
								if (Test-Path -LiteralPath $CaminhoScriptDownload -PathType Leaf) {
									Remove-Item -LiteralPath $CaminhoScriptDownload -Force -ErrorAction Stop
								}

								if (Test-Path -LiteralPath $CaminhoScriptBackup -PathType Leaf) {
									Remove-Item -LiteralPath $CaminhoScriptBackup -Force -ErrorAction Stop
								}
								
								if ( -not (Test-Path -LiteralPath $CaminhoScriptDownload -PathType Leaf) -and
									 -not (Test-Path -LiteralPath $CaminhoScriptBackup -PathType Leaf)) {
										Write-Host "[SUCESSO] Os arquivos temporários foram excluídos com êxito."
									}
									else {
										Write-Host "[ERRO] Não foi possível excluir os arquivos temporários. Realize a remoção manualmente."
										exit 1
									}

							} else {
								Write-Host "[ERRO] Falha no processo de atualização. Revertendo as modificações realizadas..."
								Start-Sleep -Seconds 2
								Write-Host "[INFO] Iniciando a restauração do backup..."
								
								# SUBSTITUI O SCRIPT ATUAL PELO BAIXADO
								Copy-Item -LiteralPath $CaminhoScriptBackup -Destination $CaminhoScriptAtual -Force -ErrorAction Stop
								
								# CAPTURA O CONTEUDO DO ARQUIVO DE BACKUP
								$ConteudoScriptBackup = [System.IO.File]::ReadAllText($CaminhoScriptBackup)
								
								# CAPTURA O CONTEUDO DO ARQUIVO ATUAL
								$ConteudoScriptAtual = [System.IO.File]::ReadAllText($CaminhoScriptAtual)
								
								if ($ConteudoScriptAtual -ceq $ConteudoScriptBackup) {
									Write-Host "[SUCESSO] A restauração do backup foi concluída, a versão anterior foi recuperada!"
									Start-Sleep -Seconds 2
									Write-Host "[INFO] Iniciando a exclusão dos arquivos temporários..."
								
								if (Test-Path -LiteralPath $CaminhoScriptDownload -PathType Leaf) {
									Remove-Item -LiteralPath $CaminhoScriptDownload -Force -ErrorAction Stop
								}

								if (Test-Path -LiteralPath $CaminhoScriptBackup -PathType Leaf) {
									Remove-Item -LiteralPath $CaminhoScriptBackup -Force -ErrorAction Stop
								}
								
								if ( -not (Test-Path -LiteralPath $CaminhoScriptDownload -PathType Leaf) -and
									 -not (Test-Path -LiteralPath $CaminhoScriptBackup -PathType Leaf)) {
										Write-Host "[SUCESSO] Os arquivos temporários foram excluídos com êxito."
									}
									else {
										Write-Host "[ERRO] Não foi possível excluir os arquivos temporários. Realize a remoção manualmente."
										exit 1
									}
									
								} else {
								
									Write-Host "[ERRO] Ocorreu um erro durante o processo. A restauração do backup não pôde ser concluída."
									
									
									
								}
							}
								
						} else {
							
							Write-Host "[ERRO] Foi detectada uma falha no arquivo de backup!"
							Start-Sleep -Seconds 2
							Write-Host "[INFO] Excluindo o backup criado durante o processo..."
							Remove-Item -LiteralPath $CaminhoScriptBackup -Force -ErrorAction Stop
													
						}
						
					} else {
						Write-Host "[ERRO] Falha ao realizar a cópia de segurança do script atual."
						exit 1
					}
				
			} else {
				
				Write-Host "[ERRO] O conteudo do arquivo temporario diverge do conteudo remoto."
                Write-Host "[INFO] A atualizacao foi cancelada por falha na validacao."
				
				Write-Host "[ERRO] O conteúdo do arquivo é diferente do conteúdo do GitHub."
				Remove-Item -LiteralPath $CaminhoScriptDownload -Force
			}
						
		} else {
			Write-Host "[ERRO] Não foi possível concluir o download do script."
			exit 1
		}
		
	} else {
		Write-Host "[AVISO] Nenhuma atualização necessária. A versão atual corresponde à versão publicada. [Versao Local: $VersaoLocal Versao Git: $VersaoRemota]"
		exit 0
	}
	
} catch {
	Write-Host  "[ERRO] Falha durante o processo de atualização do script."
	exit 1
}
