<%@ tag body-content="scriptless" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://localhost/jeetags" prefix="siga"%>
<%@ taglib uri="http://localhost/sigasrtags" prefix="sigasr"%>

<%@ attribute name="metodo" required="true"%>
<%@ attribute name="exibeLotacaoNaAcao" required="false"%>

<div id="${metodo}" class="gt-form-row">
	<label>Produto, Servi&ccedil;o ou Sistema relacionado &agrave; Solicita&ccedil;&atilde;o</label>
	<siga:selecao2 propriedade="solicitacao.itemConfiguracao" 
		tipo="itemConfiguracao" 
		tema="simple" 
		modulo="sigasr" 
		tamanho="grande"
		onchange="dispararFuncoesOnBlurItem();"
		checarInput="true"
		paramList="sol.solicitante.id=${solicitante.idPessoa};sol.local.id=${local.idComplexo};sol.titular.id=${cadastrante.idPessoa};sol.lotaTitular.id=${lotaTitular.idLotacao}" />
	<br/><span id="itemNaoInformado" style="color: red; display: none;">Item não informado</span>
	<br/>
	<div id="divAcao" depende="solicitacao.itemConfiguracao">
		
		<c:set var="acoesEAtendentes" value="${solicitacao.acoesEAtendentes}" />
		<c:if test="${not empty solicitacao.itemConfiguracao && not empty acoesEAtendentes}"> 
			<div class="gt-form-row">
				<label>A&ccedil;&atilde;o</label>	
				<select name="solicitacao.acao.id" id="selectAcao" onchange="carregarAcao();">
					<c:forEach items="${acoesEAtendentes.keySet()}" var="cat">
						<optgroup  label="${cat.tituloAcao}">
							<c:forEach items="${acoesEAtendentes.get(cat)}" var="tarefa">
								<option value="${tarefa.acao.idAcao}" ${solicitacao.acao.idAcao.equals(tarefa.acao.idAcao) ? 'selected' : ''}> 
									${tarefa.acao.tituloAcao}
									<c:if test="${exibeLotacaoNaAcao == true}">(${tarefa.conf.atendente.siglaCompleta})</c:if>
								</option>
							</c:forEach>					 
						</optgroup>
					</c:forEach>
				</select>
				<br/><span id="acaoNaoInformada" style="color: red; display: none;">Ação não informada</span>
			</div>
		</c:if>
		<div id="divAtributos" depende="solicitacao.acao">	
			<sigasr:atributo atributoSolicitacaoMap="${atributoSolicitacaoMap}" 
				atributoAssociados="${atributoAssociados}"
				entidade="solicitacao" />
		</div>
	</div>
</div>
<script>
$(document).ready(function($) {
	limparMensagem();	
});

function validarCampos() {
	$("#itemNaoInformado").hide();
	$("#erroJustificativa").hide();

	if (!$("#formulario_solicitacaoitemConfiguracao_id").val()){
		$("#itemNaoInformado").show();
		return false;
	}
	if (!$("#selectAcao").val()) {
		$("#acaoNaoInformada").show();
		return false;
	}
	return true;
}

function carregarAcao() {
	sbmt('solicitacao.acao', postbackURL()+'&solicitacao.acao.id='+$("#selectAcao").val(), true);
}

function dispararFuncoesOnBlurItem() {
	$('#itemNaoInformado').hide();
	sbmt('solicitacao.itemConfiguracao', null, false, carregarAcao);
}

/**
 * Limpa o span que contem mensagem informando que determinado input nao foi informado
 * assim que começar a digitar nesse input
 */
function limparMensagem() {
	$("#${metodo}").on("keyup", "input", function() {
		$(this).next("span.error").text("");
	});
}

// retirar esse metodo daqui. Nao esta intuitivo que ele existe dentro do classificacao.tag
function gravar() {
	if (!validarCampos()) 
		return false; 
	
	$.ajax({
    	type: "POST",
    	url: submitURL(),
    	data: $("#${metodo}").closest("form").serialize(),
    	dataType: "text",
    	"beforeSend": function () {
    		jQuery.blockUI(objBlock);
    	},
    	success: function(response) {
        	${metodo}_fechar();
    		jQuery.unblockUI();
        	window.location.href = "${linkTo[SolicitacaoController].exibir}${siglaCompacta}";
    	},
    	error: function(response) {
        	//criar funcao separa para tratar dos erros  		
			if (response.getResponseHeader('Validation') === "true") {
				$("span.error").remove();
	        	var errors = JSON.parse(response.responseText);
	      		for(var i = 0; i < errors.length; i++) {
	     			var span = $('&nbsp<span class="error" style="color: red"></span>');
	     			span.html(errors[i].message);
	      			span.insertAfter($("[name='" + errors[i].category + "']"));
	      		}
			}
			else 
				carregouAjaxserver_error(response.responseText, $("#responseText"));
			jQuery.unblockUI();
        }
   	});
}
</script>