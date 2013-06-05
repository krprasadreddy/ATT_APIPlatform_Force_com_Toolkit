/**
* @description Facade class used to invoke AT&T Speech To Text API.
*/
public virtual class AttSpeech {

		/**
		 * @description Authorization object.
		 */
		public AttClientCredentialsAuthorization auth { get; set; }

		/**
		 * @description Ennumeration of supported content languages.
		 */
		public enum SpeechContentLanguage {ENGLISH_US, SPANISH_US}
		
		/**
		* @description Ennumeration of supported audio file types.
		*/
		public enum FileType {WAV, AMR, AMRWB, XWAV, XSPEEX}

		/**
		* @description Ennumeration of supported speech contexts.
		*/
		public enum SpeechContext {GENERIC, TV, BUSINESSSEARCH, WEBSEARCH, SMS, VOICEMAIL, QNA, GAMING, SOCIALMEDIA}
		
		protected Set<String> possibleSubContexts = new Set<String> {
			'Chat', 'AlphadigitList', 'AlphadigitSingle', 'AlphaList', 'AlphaSingle', 'DigitList_1-2', 
			'DigitList_1-3', 'DigitList_1-4', 'DigitList_1-5', 'DigitList_1-6', 'DigitList_1-7', 
			'DigitList_1-8', 'DigitList_1-9', 'DigitList', 'DigitSingle_1-10', 'DigitSingle_1-2', 
			'DigitSingle_1-3', 'DigitSingle_1-4', 'DigitSingle_1-5', 'DigitSingle_1-6', 'DigitSingle_1-7', 
			'DigitSingle_1-8', 'DigitSingle_1-9', 'DigitSingle ', 'PetCmd', 'Rpg', 'RpgActn', 
			'RpgActnActiv', 'RpgActnExam', 'RpgActnOpenclose', 'RpgActnPushpull', 'RpgActnAccept', 
			'RpgEmotes', 'RpgEmotesBasic', 'RpgEmotesComm', 'RpgEmotesExpr', 'RpgEmotesGreet', 
			'RpgEmotesHibye', 'RpgEmotesMoodact', 'RpgEmotesMoodstate', 'RpgEmotesVerbal', 'RpgMagicSpell', 
			'RpgMotion', 'RpgMotionGetupgetdownliedown', 'RpgMotionGowait', 'RpgMotionMoveflyjumphide', 
			'RpgMotionRunwalkfollowcrawlstop', 'RpgTeamCheer', 'SportChess ', 'SportFootballScrimmage', 
			'SportGolf', 'SportGolfCaddie', 'SportGolfClub', 'SportGolfAction', 'SportRacecar', 
			'SportRacecarCarinfo', 'SportRacecarPit', 'SportRacecarRaceinfo', 'Ui', 'UiBrowser', 
			'UiContinueresumehelp', 'UiDiscplayer', 'UiHerethere', 'UiHilo', 'UiHorvert', 'UiMoreless', 
			'UiRotateflip', 'UiUnderaboveover', 'UiUpdown', 'War', 'WarAnarchy', 'WarCombat'
		};

        // Speech Content Language Map
        protected Map<AttSpeech.SpeechContentLanguage, String> contentLanguageMap = new Map<AttSpeech.SpeechContentLanguage, String> {
        	AttSpeech.SpeechContentLanguage.ENGLISH_US => 'en-US',
        	AttSpeech.SpeechContentLanguage.SPANISH_US => 'es-US'
        };

		// Content types map
        protected Map<AttSpeech.FileType, String> audioTypeMap = new Map<AttSpeech.FileType, String> {
        	AttSpeech.FileType.WAV => 'audio/wav',
        	AttSpeech.FileType.AMR => 'audio/amr',
        	AttSpeech.FileType.AMRWB => 'audio/amr-wb',
			AttSpeech.FileType.XWAV => 'audio/x-wav',
			AttSpeech.FileType.XSPEEX => 'audio/x-speex'
        };
        
        // Speech context
        protected Map<AttSpeech.SpeechContext, String> contextMap = new Map<AttSpeech.SpeechContext, String> {
        	AttSpeech.SpeechContext.GENERIC => 'Generic',
        	AttSpeech.SpeechContext.TV => 'TV',
        	AttSpeech.SpeechContext.BUSINESSSEARCH => 'BusinessSearch',
        	AttSpeech.SpeechContext.WEBSEARCH => 'Websearch',
        	AttSpeech.SpeechContext.SMS => 'SMS',
        	AttSpeech.SpeechContext.VOICEMAIL => 'Voicemail',
        	AttSpeech.SpeechContext.QNA => 'QuestionAndAnswer',
        	AttSpeech.SpeechContext.GAMING => 'Gaming',
        	AttSpeech.SpeechContext.SOCIALMEDIA => 'SocialMedia'
        };
        
        /**
		 * @description Property for setting/getting content language. The default value is ENGLISH_US.
		 */
        public AttSpeech.SpeechContentLanguage contentLanguage { get; set; }

		/**
		* @description Property for setting/getting speech context. The default value is GENERIC.
		*/
        public AttSpeech.SpeechContext speechContext { get; set; }
        
        /**
		 * @description Property for setting/getting speech sub context. The value is only read if speechContext is set to GAMING.
		 */
        public String speechSubContext { get; 
        	set {
        		if(possibleSubContexts.contains(value)) {
        			speechSubContext = value;
        		} else {
        			speechSubContext = null;
        		}
        	}
        }
        
        /**
		 * @description Property for setting/getting xArg Parameters. Generates a the xArg header string
		 */
        public Map<String, String> xArg { get; set; }

		/**
		* @description Property for setting/getting file type.
		*/
        public AttSpeech.FileType fileType { get; set; }

		/**
		* @description Property for setting/getting binary audio data.
		*/
        public Blob fileBlob { get; set; }
        
		/**
		* @description Constructs Speech service with authorization instance.
		* @param auth instance for client authentication.
		*/
		public AttSpeech(AttClientCredentialsAuthorization auth) {
			this.auth = auth;
			speechContext = AttSpeech.SpeechContext.GENERIC;
			this.xArg = new Map<String, String>();
		}
		
		private virtual void validateParameters() {
			if (fileType == null) {
				throw new AttException('File type is required parameter.'); 
			}        	
			
			if (fileBlob == null) {
				throw new AttException('File BLOB is required parameter.'); 
			}        	
		}

		protected virtual String getContentLanguageAsString() {
        	String language = contentLanguageMap.get(contentLanguage); 
        	
        	if (String.isBlank(language)) {
	        	language = contentLanguageMap.get(AttSpeech.SpeechContentLanguage.ENGLISH_US);
        	}
        	
			return language;
		}

		protected virtual String getSpeechContextAsString() {
        	String context = contextMap.get(speechContext); 
        	
        	if (String.isBlank(context)) {
	        	context = contextMap.get(AttSpeech.SpeechContext.GENERIC);
        	}
        	
			return context;
		}
		
		protected String getSpeechSubContext() {
			//Make sure the speechSubContext is valid
			return speechSubContext;
		}
		
		private String urlEncode(String input) {
			return EncodingUtil.urlEncode(input, 'UTF-8');
		}
		
		protected virtual String getXArgAsString() {
    		String xArgString = '';
    		if(xArg != null) {
				for(String xArgName : xArg.keySet()) {
					String xArgValue = xArg.get(xArgName);
					if(!xArgString.equals('')) xArgString += ',';
					xArgString += urlEncode(xArgName) + '=' + urlEncode(xArgValue);
				}
    		}
    		
    		return xArgString;
		}
		
		protected virtual String getFileTypeAsString() {
    		return audioTypeMap.get(fileType);
		}
		
		/**
		* @description Send audio file data to AT&T speech service to convert it to text.
		* @return AttSpeechResult instance.
		*/
        public virtual AttSpeechResult convert() {
        	AttSpeechResult result = null;

			validateParameters();
				    		
			String accessToken = auth.getAccessToken();        	

        	String context = getSpeechContextAsString();
        	
        	String subContext = getSpeechSubContext();

    		String audioType = getFileTypeAsString();
    		
    		String language = getContentLanguageAsString();
    		
    		String xArgString = getXArgAsString();
    		
    		HttpClient client = UtilityFactory.getHttpClient();
    	
            HttpRequest request = client.createRequest(ServiceConstants.ServiceType.SPEECH);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Accept', 'application/json');
            
            request.setHeader('Content-Language', language);
            
            request.setHeader('X-SpeechContext', context);
            
            if(!String.isBlank(subContext)) {
            	request.setHeader('X-SpeechSubContext', speechSubContext);
            }
            
            if(!String.isBlank(xArgString)) {
            	request.setHeader('X-Arg', xArgString);
            }
            
            // set content type for current file 
            request.setHeader('Content-Type', audioType);
            
            // set Blob type only with this method, dont use setBody() !
            request.setBodyAsBlob(fileBlob);            
			HttpResponse response = client.sendRequest(request);
	            
            // check response code
            UtilityFactory.getRestErrorHandler().checkResponseCode(response);
            String responseBody = String.escapeSingleQuotes(response.getBody());

			// all is good - so parse right result
			result = AttSpeechResult.parse(responseBody); 

            return result;
        }
}