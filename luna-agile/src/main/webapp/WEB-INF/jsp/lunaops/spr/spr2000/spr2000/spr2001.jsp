<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<form class="kt-form" id="frSpr2001" autocomplete="off">
	<input type="hidden" name="type" id="type" value="<c:out value='${param.type}'/>">
	<input type="hidden" name="rptId" id="rptId" value="<c:out value='${param.rptId}'/>">
	<input type="hidden" name="sprId" id="sprId" value="<c:out value='${param.sprId}'/>">
	<input type="hidden" name="paramSprNm" id="paramSprNm" value="<c:out value='${param.sprNm}'/>">
	<div class="kt-portlet">
		<div class="kt-portlet__body">
		<div class="form-group">
			<label class="required"><i class="fa fa-edit kt-margin-r-5"></i><span data-lang-cd="spr2001.label.sprNm">스프린트명</span></label>
			<input type="text" class="form-control" name="sprNm" id="sprNm" readonly="readonly" required>
		</div>
		<div class="row">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<div class="form-group">
					<label><i class="fa fa-user-friends kt-margin-r-5"></i>
						<span data-lang-cd="spr2001.label.rptMem">참여 인원</span>
						<span class='kt-badge kt-badge--metal kt-badge--inline kt-padding-10 kt-hide' id='memCnt' name='memCnt'>0</span>
					</label>
					<select class="form-control kt-select2 select2-hidden-accessible" id="rptMemSelect" name="rptMemSelect" multiple="" data-select2-id="rptMemSelect" tabindex="-1" aria-hidden="true"></select>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<div class="form-group">
					<label class="required"><i class="fa fa-edit kt-margin-r-5"></i><span data-lang-cd="spr2001.label.rptNm">회의록 제목</span></label>
					<input type="text" class="form-control" id="rptNm" name="rptNm" placeholder="제목" maxlength="80" required>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<div class="form-group form-group-last">
					<label class="required"><i class="fa fa-edit kt-margin-r-5"></i><span data-lang-cd="spr2001.label.rptDesc">회의록 내용</span></label>
					<textarea class="form-control kt-hide" name="rptDesc" id="rptDesc" required></textarea>
				</div>
			</div>
		</div>
	</div>
</form>
<div class="modal-footer">
	<button type="button" class="btn btn-brand" id="spr2001SaveSubmit"><i class="fa fa-check-square"></i><span data-lang-cd="spr2001.submit">완료</span></button>
	<button type="button" class="btn btn-outline-brand" data-dismiss="modal"><i class="fa fa-window-close"></i><span data-lang-cd="modal.close">Close</span></button>
</div>
<!-- begin page script -->
<script>
"use strict";
var OSLSpr2001Popup = function () {
	var formId = 'frSpr2001';
	
	//edit 목록
	var formEditList = [];
	
	//form validate 주입
	var formValidate = $.osl.validate(formId);

	//type
	var type;

	//참여 인원 id를 담을 변수 선언
	var usrList = [];
	
	// Private functions
    var documentSetting = function () {
    	
    	type = $("#type").val();
    	
    	//kt-select2 설정
		$('#rptMemSelect').select2({
			placeholder : $.osl.lang("spr2001.placeholder.select2") + "("+$.osl.lang("spr2001.message.select2")+")",
			templateResult: optionFormatState,
			templateSelection : tagFormatState,
			dropdownParent: $("#frSpr2001"),
		});

		//select2 클릭 이벤트
		$('#rptMemSelect').on('select2:close', function (evt) {
	        var count = $(this).select2('data').length;
	        if(count==0){
				$("#memCnt").text("0");
	        	$("#memCnt").addClass("kt-hide");
	        }
	        else{
	        	$("#memCnt").text(count);
	        	$("#memCnt").removeClass("kt-hide");
	        }
		});
		
    	//문구 세팅 
    	$("#spr2001SaveSubmit > span").text($.osl.lang("spr2001.button."+type+"Btn"));
    	
    	//placeholder 세팅
    	$("#rptNm").attr("placeholder", $.osl.lang("spr2001.placeholder.rptNm"));

    	//등록인경우
    	if(type == "insert"){
    		//선택한 스프린트 id에 해당하는 이름으로 지정
    		$("#sprNm").val($("#paramSprNm").val());

    		$("#memCnt").text(0);
    		
    		//사용자 리스트 세팅
        	selectUsrList();
        	
    		//edit 세팅
    		formEditList.push($.osl.editorSetting("rptDesc", {formValidate: formValidate,height:190, 'minHeight': 190, disableResizeEditor: false}));
	    	//edit 세팅하고 나서 textarea 보이기
	    	$("#rptDesc").removeClass("kt-hide");
    	
    	}else{
    		//수정
    		//스프린트 회의록 정보 조회 및 세팅
    		selectSprRptInfo();
    	}
    	
    	//submit 동작
    	$("#spr2001SaveSubmit").click(function(){
			var form = $('#'+ formId);    		
			
			//폼 유효 값 체크
    		if (!form.valid()) {
    			return false;
    		}
    		
    		$.osl.confirm($.osl.lang("spr2001.saveString."+type+"Str"),null,function(result) {
    	        if (result.value) {
    	        	if(type=="insert"){
    	        		submitInsertAction();
    	        	}else{
    	        		submitUpdateAction();
    	        	}
    	        }
    		});
    	});
    };

    /**
    * kt-select2 옵션
    */
    var optionFormatState = function(state){
    	if (!state.id) {
    	    return state.text;
   	 	}
    	var usrId = state.id;
    	var usrNm = state.element.attributes.getNamedItem("data-usr-nm").value;
    	var usrImgId = state.element.attributes.getNamedItem("data-usr-img-id").value;
    	var usrEmail = state.element.attributes.getNamedItem("data-usr-email").value;

    	var state = $(
    			'<div class="kt-user-card-v2 btn" data-usr-id="'+ usrId +'">' 
				+'<div class="kt-user-card-v2__pic kt-media kt-media--sm kt-media--circle">'
					+'<img src="'+$.osl.user.usrImgUrlVal(usrImgId)+'" onerror="this.src=\'/media/users/default.jpg\'"/>'
				+'</div>'
				+'<div class="kt-user-card-v2__details float-left">'
					+'<span class="kt-user-card-v2__name float-left">'+usrNm+'</span>'
					+'<span class="kt-user-card-v2__email float-left kt-margin-l-10 osl-line-height-rem-1_5">'+usrEmail+'</span>'
				+'</div>'
			+'</div>'
   	    );
    	
    	return state;
    };
    
    /**
     * kt-select2 태그 옵션
     */
    var tagFormatState = function(state){
    	if (!state.id) {
    	    return state.id;
   	 	}
    	var usrId = state.id;
    	var usrNm = state.element.attributes.getNamedItem("data-usr-nm").value;
    	var usrImgId = state.element.attributes.getNamedItem("data-usr-img-id").value;
    	var usrEmail = state.element.attributes.getNamedItem("data-usr-email").value;

    	var state = $(
    			'<div class="kt-user-card-v2 d-inline-block" data-usr-id="'+ usrId +'">'
					+'<div class="kt-user-card-v2__pic kt-media kt-media--sm kt-media--circle float-left">'
						+'<img src="'+$.osl.user.usrImgUrlVal(usrImgId)+'" onerror="this.src=\'/media/users/default.jpg\'"/>'
					+'</div>'
					+'<div class="kt-user-card-v2__details float-left">'
						+'<span class="kt-user-card-v2__name">'+usrNm+'</span>'
						+'<span class="kt-user-card-v2__email">'+usrEmail+'</span>'
					+'</div>'
				+'</div>'
   	    );
    	
   	    return state;
    };
    
    /**
    * kt-select2 사용자 세팅
    * param : selectUsrList 이미 선택된 사용자 리스트
    */
	var selectUsrList = function(selectedUsrList){
		//AJAX 설정
		var ajaxObj = new $.osl.ajaxRequestAction(
				{"url":"<c:url value='/spr/spr2000/spr2000/selectSpr2001RptUsrListAjax.do'/>", "async":"true"});
		
		//AJAX 전송 성공 함수
		ajaxObj.setFnSuccess(function(data){
			if(data.errorYn == "Y"){
				$.osl.alert(data.message,{type: 'error'});

				//모달 창 닫기
				$.osl.layerPopupClose();
			}else{
				//사용자 선택 드롭박스 추가
				$.each(data.usrAllList, function(idx, value){
					var usrData = {
							html: value.usrNm,
							imgSize: "sm",
							class:{
								cardBtn: "osl-width__fit-content"
							}
					};
					
					var str = '';
					if(selectedUsrList != null && selectedUsrList.length>0){
						//등록된 참여 인원이 있으므로
						$("#memCnt").text(selectedUsrList.length);
	        			$("#memCnt").removeClass("kt-hide");
	        	
						//수정 시 이미 등록된 참여인원인지 확인
						var check = false;
						$.each(selectedUsrList, function(index, item){
							if(item.usrId === value.usrId){
								check = true;
							}
						});
						if(check){
							str = '<option selected="selected" value="' + value.usrId + '" data-usr-nm="'+value.usrNm+'" data-usr-img-id="'+value.usrImgId+'" data-usr-email="'+value.email+'">' 
									+ value.usrNm
								+ '</option>';
						}else{
							str = '<option value="' + value.usrId + '" data-usr-nm="'+value.usrNm+'" data-usr-img-id="'+value.usrImgId+'" data-usr-email="'+value.email+'">' 
									+ value.usrNm
								+ '</option>';
						}
					}else{
						str = '<option value="' + value.usrId + '" data-usr-nm="'+value.usrNm+'" data-usr-img-id="'+value.usrImgId+'" data-usr-email="'+value.email+'">' 
									+ value.usrNm
								+ '</option>';
					}
					
					$("#rptMemSelect").append(str);
				});
			}
		});
		//AJAX 전송
		ajaxObj.send();
	};
	
    /**
	 * 	스프린트 회의록 정보 조회
	 */
	 var selectSprRptInfo = function() {
    	var data = {
    			rptId :  $("#rptId").val(),
    			sprId :  $("#sprId").val(),
    	};

		//AJAX 설정
		var ajaxObj = new $.osl.ajaxRequestAction(
				{"url":"<c:url value='/spr/spr2000/spr2000/selectSpr2000RptInfoAjax.do'/>", "async":"true"}
				,data);
		//AJAX 전송 성공 함수
		ajaxObj.setFnSuccess(function(data){
			if(data.errorYn == "Y"){
				$.osl.alert(data.message,{type: 'error'});

				//모달 창 닫기
				$.osl.layerPopupClose();
			}else{
				//수정할때 호출
		    	$.osl.setDataFormElem(data.rptInfo,"frSpr2001");
		
				//참여 인원 정보 넣기
				var rptMemList = data.rptMemList;
				selectUsrList(rptMemList);
								
	    		//edit 세팅
	    		formEditList.push($.osl.editorSetting("rptDesc", {formValidate: formValidate,height:190, 'minHeight': 190, disableResizeEditor: false}));
	    		//edit 세팅하고 나서 textarea 보이기
		    	$("#rptDesc").removeClass("kt-hide");
			}
		});
		
		//AJAX 전송
		ajaxObj.send();
	};
    
	/**
	 * 	스프린트 회의록 등록
	 */
    var submitInsertAction = function(){
    	var form = $('#'+formId);    		
    	
		//폼 유효 값 체크
		if (!form.valid()) {
			return;
		}

       	//formData
   		var fd = $.osl.formDataToJsonArray(formId);
       	
       	//회의 참여자 목록 가져오기
		addUsrList(true);
       	fd.append("idList", JSON.stringify(usrList));
       	
       	//작성자 정보 넣기
       	fd.append("rptUsrId", $.osl.user.userInfo.usrId);

		//AJAX 설정
   		var ajaxObj = new $.osl.ajaxRequestAction({"url":"<c:url value='/spr/spr2000/spr2000/insertSpr2001RptInfoAjax.do'/>"
   			, "loadingShow": false, "async": false,"contentType":false,"processData":false ,"cache":false}
			,fd);

   		//AJAX 전송 성공 함수
   		ajaxObj.setFnSuccess(function(data){
   			if(data.errorYn == "Y"){
   				$.osl.alert(data.message,{type: 'error'});
   			}else{
   				//등록 성공
   				$.osl.toastr(data.message);

   				//모달 창 닫기
   				$.osl.layerPopupClose();
   				
   				//전체 목록 재조회
   				OSLSpr1100Popup.reload();
   			}
   		});
   		
   		//AJAX 전송
   		ajaxObj.send();
    };
    
    /**
	 * 	스프린트 회의록 수정
	 */
    var submitUpdateAction = function(){
		var form = $('#'+formId);    		
    	
		//폼 유효 값 체크
		if (!form.valid()) {
			return;
		}

       	//formData
   		var fd = $.osl.formDataToJsonArray(formId);

       	//회의 참여자 목록 가져오기
		addUsrList(true);
       	fd.append("idList", JSON.stringify(usrList));

       	//AJAX 설정
   		var ajaxObj = new $.osl.ajaxRequestAction(
   				{"url":"<c:url value='/spr/spr2000/spr2000/updateSpr2001RptInfoAjax.do'/>"
   					, "loadingShow": false, "async": false,"contentType":false,"processData":false ,"cache":false}
   				,fd);

   		//AJAX 전송 성공 함수
   		ajaxObj.setFnSuccess(function(data){
   			if(data.errorYn == "Y"){
   				$.osl.alert(data.message,{type: 'error'});
   			}else{
   				//등록 성공
   				$.osl.toastr(data.message);

   				//모달 창 닫기
   				$.osl.layerPopupClose();
   				
   				//전체 목록 재조회
   				OSLSpr2000Popup.reload();
   			}
   		});
   		
   		//AJAX 전송
   		ajaxObj.send();
    };
    
    /**
	* function 명 	: addUsrList
	* function 설명	: 참여 인원 리스트 전달
	* param : defaultCheck 넘길 리스트가 null일 때 현재 사용자 정보 넣을지 확인(필요 true, 필요 없음false)
	*/
    var addUsrList = function(defaultCheck){

		var optionList = $(".select2-selection__rendered").children("li.select2-selection__choice");
		
		$.each(optionList, function(index, value){
			usrList.push($(value).children("div").data("usr-id"));
		});
		
		if(defaultCheck){
			if(usrList.length == 0){
				usrList.push($.osl.user.userInfo.usrId);
			}
		}
	};

	return {
        // public functions
        init: function() {
        	documentSetting();
        },
    };
}();

// Initialization
$.osl.ready(function(){
	OSLSpr2001Popup.init();
});

	
</script>