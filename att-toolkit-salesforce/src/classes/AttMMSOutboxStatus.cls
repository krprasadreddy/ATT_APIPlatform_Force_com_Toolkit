/**
 * @description Represent MMS sending status. Provide MMS id and url that can be used for check MMS delivery status.
 * Also contain method getDeliveryStatus() that perform call to ATT and return delivery status (see AttMessageDeliveryStatus)
 */
public class AttMMSOutboxStatus extends BaseOutboxStatus {
		
	private AttClientCredentialsAuthorization auth{ get; set; }
   	private HttpClient client { get; set; }
   	
   	/**
	 * @description Don't create this class directly, use AttMMSOutbox.sendMessage instead 
	 */
   	public AttMMSOutboxStatus(String json, AttClientCredentialsAuthorization auth) {
   		super(json);
   		this.auth = auth;
	}
	
	/**
	 * @description Don't create this class directly, use AttMMSOutbox.sendMessage instead 
	 */
	public AttMMSOutboxStatus(String id, String resourceUrl, AttClientCredentialsAuthorization auth) {
   		super(id, resourceUrl);
   		this.auth = auth;
	}
	
	/**
	 * @description Call this method to get delivery status. 
	 * It perform call to AT&T service, one transaction to MMS Get Delivery Status service is made. 
	 * Transaction limits: https://devconnect-api.att.com/docs/att-apis/overview
	 * @return AttMessageDeliveryStatus object that represent delivery status
	 */
	public AttMessageDeliveryStatus getDeliveryStatus() {
   		if (client == null) client = UtilityFactory.getHttpClient();

   		String accessToken = auth.getAccessToken();

        HttpRequest req = client.createRequest(this.resourceUrl);
        req.setMethod('GET'); 
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader('MIME-Version', '1.0');
        
        HTTPResponse resp = client.sendRequest(req);
        UtilityFactory.getRestErrorHandler().checkResponseCode(resp);
        return new AttMessageDeliveryStatus(resp.getBody());
	}
    
    /**
	 * DTO objects that reflect AT&T response structure
	 */
    private class MMSOutboxStatus {
    	private OutboxStatus outboundMessageResponse {get;set;}
    }
    
    protected override OutboxStatus getOutboxStatus(string json) {
   		MMSOutboxStatus rez;
   		try {
			rez = (MMSOutboxStatus) System.JSON.deserialize(json, MMSOutboxStatus.class);
		} catch (Exception e) {
			throw new AttException('Cant parse response: ' + json, e);
		}
		
		if (rez.outboundMessageResponse == null) throw new AttException('Response doesnt contain valid wrapper: ' + json);
		return rez.outboundMessageResponse;
   	}
}