public class DemoSpeechController {
        
    // File extensions
    private static String UPLOADED_FILE_TYPE_WAV = '.wav';
    private static String UPLOADED_FILE_TYPE_AMR = '.amr';
    
    public String debugBody {get; set;}
    
    public String clientToken {get; set; }
    
    public String fileName {get; set;}
    
    public String fileNameReal {get; set;}
    
    public Blob fileBlob {get; set;}
    
    //header values
    public String context {
        get {
            if(context==null) context='GENERIC';
            return context;
        }
        set;
    }
    
    public String subContext {get; set;}
    
    public String contentLanguage {get; set;}
    
    public Map<String, String> xArgs {get; set;}
    
    // binding result values to page controls
    public String resGrade { get; set; }
    
    public String resConfidence { get; set; }
    
    public String resLanguageId { get; set; }
    
    public String resHypothesis { get; set; }
    
    public String resResultText { get; set; }
    
    public String resWordScores { get; set; }
    
    public AttClientCredentialsAuthorization auth { get; set; }
    
    private final System.Type TEST_CLASS = TestDemoSpeechController.class;
    
    private AttSpeechOptionsGenerator optionsGenerator { get; set; }

    /**
    *
    * Default constructor.
    *
    */
    public DemoSpeechController () {
        init();
        auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.SPEECH);
        optionsGenerator = new AttSpeechOptionsGenerator(auth);
    }
    
    private void init() {
        fileName = '';
        fileNameReal = '';
        fileBlob = null;
    }
    
    private void clearControlsValue() {
        debugBody = '';
        
        resGrade = '';
        resConfidence = '';
        resLanguageId = '';
        resHypothesis = '';
        resResultText = '';
        resWordScores = '';
    }
    
    private AttSpeech.SpeechContext getSpeechContextByName(String name) {
        for(AttSpeech.SpeechContext enumVal : AttSpeech.SpeechContext.values()) {
            if(enumVal.name().equals(name)) return enumVal;
        }
        return null;
    }
    
    private AttSpeech.SpeechContentLanguage getSpeechContentLanguageByName(String name) {
        for(AttSpeech.SpeechContentLanguage enumVal : AttSpeech.SpeechContentLanguage.values()) {
            if(enumVal.name().equals(name)) return enumVal;
        }
        return null;
    }
    
    public void testAttServiceSpeech() {
        clearControlsValue();
        
        if (fileNameReal == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select file before send request...');
            ApexPages.addMessage(msg);
            init();
            return;
        }

        AttSpeech.FileType fileType = null;
        if (fileNameReal.toLowerCase().endsWith(UPLOADED_FILE_TYPE_WAV)) {
            fileType = AttSpeech.FileType.WAV;
        } else if (fileNameReal.toLowerCase().endsWith(UPLOADED_FILE_TYPE_AMR)) {
            fileType = AttSpeech.FileType.AMR;
        } else {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Speech service support only \'wav\' and \'amr\' audio files.');
            ApexPages.addMessage(msg);
            init();
            return;
        }

        if (fileBlob.size() > 3000000) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'File size must be not greater than 3,000,000 bytes.');
            ApexPages.addMessage(msg);
            init();
            return;
        }
        
        AttSpeech speech = new AttSpeech(auth);
        speech.speechContext = getSpeechContextByName(context);
        if(speech.speechContext == AttSpeech.SpeechContext.GENERIC) {
            speech.contentLanguage = getSpeechContentLanguageByName(contentLanguage);
        } else if(speech.speechContext == AttSpeech.SpeechContext.GAMING) {
            speech.speechSubContext = subContext;
        }
        speech.fileType = fileType;
        speech.fileBlob = fileBlob;
        
        //Example of adding variables to the xArg:
        //speech.xArg.put('HasMultipleNBest', 'true');
        
        AttSpeechResult response = null;
        
        try {
            response = speech.convert();
            debugBody = 'fileName=' + fileNameReal + 
                '\r\ncontentLegth=' + fileBlob.size() + '\r\n\r\n' + response;
        } catch(Exception ex) {
            System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            init();
            return;
        }
        
        AttSpeechResult.Recognition recogn = response.Recognition;
        
        AttSpeechResult.NBest nbest = recogn.NBest[0];
        
        resGrade = nbest.Grade;
        resConfidence = '' + nbest.Confidence;
        resLanguageId = nbest.LanguageId;
        resHypothesis = nbest.Hypothesis;
        resResultText = nbest.ResultText;
        
        List<Double> scores = nbest.WordScores;
        String resultScores = '';
        for(Double value: scores){
            resultScores += '' + value + ', ';
        } 
        resWordScores = resultScores;

        init();
    }
    
    //Class to access the variable strings in AttSpeech
    private class AttSpeechOptionsGenerator extends AttSpeech {
        
        public AttSpeechOptionsGenerator(AttClientCredentialsAuthorization auth) {
            super(auth);
        }
        
        public List<SelectOption> getSpeechContentLanguageOptions() {
            List<SelectOption> options = new List<SelectOption>();
            for(AttSpeech.SpeechContentLanguage key: contentLanguageMap.keySet()) {
                options.add(new SelectOption(key.name(), contentLanguageMap.get(key)));
            }
            return options;
        }
        
        public List<SelectOption> getSpeechContextOptions() {
            List<SelectOption> options = new List<SelectOption>();
            for(AttSpeech.SpeechContext key: contextMap.keySet()) {
                options.add(new SelectOption(key.name(), contextMap.get(key)));
            }
            options.sort();
            return options;
        }
        
        public List<SelectOption> getSpeechSubContextOptions() {
            List<SelectOption> options = new List<SelectOption>();
            for(String subContext: possibleSubContexts) {
                options.add(new SelectOption(subContext, subContext));
            }
            options.sort();
            return options;
        }
        
        public AttSpeech.SpeechContext getSpeechContextByName(String name) {
            for(AttSpeech.SpeechContext enumVal : AttSpeech.SpeechContext.values()) {
                if(enumVal.name().equals(name)) return enumVal;
            }
            return null;
        }
    }
    
    public List<SelectOption> getContentLanguageOptions() {
        return optionsGenerator.getSpeechContentLanguageOptions();
    }
    
    public List<SelectOption> getSpeechContextOptions() {
        return optionsGenerator.getSpeechContextOptions();
    }
    
    public List<SelectOption> getSpeechSubContextOptions() {
        return optionsGenerator.getSpeechSubContextOptions();
    }
}