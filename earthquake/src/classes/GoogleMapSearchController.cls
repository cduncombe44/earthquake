public class GoogleMapSearchController {
    
    public string debugResponse                 {get;set;}

    public GoogleMapSearchController() {
        
    }

    @RemoteAction
    public Static List<Earthquakes> findQuakes(Decimal n, Decimal e, Decimal s, Decimal w){

        HttpRequest myRequest = new HttpRequest();
        string url;
        url = 'http://api.geonames.org/earthquakesJSON?north=' + String.valueOf(n) + '&south=' + String.valueOf(s) + '&east=' + String.valueOf(e) + '&west=' + String.valueOf(w);
        url += '&username=cduncombe44';
      
        myRequest.setEndpoint(url);
        myRequest.setMethod('GET');
        Http h = new Http();
        HttpResponse myResponse = h.send(myRequest);
        string resultFromCall = myResponse.getBody().replace('datetime','eqdatetime');

        //Create new EQcontainer class directly from JSON
        equContainer eqCont = (equContainer)JSON.deserialize(resultFromCall, equContainer.class);

        for(Earthquakes eq : eqCont.earthquakes){
            eq.formattedDate = datetime.valueOf(eq.eqdatetime).format('M/d/yy');
            eq.formattedTime = datetime.valueOf(eq.eqdatetime).format('h:mm a');
        }

        return eqCont.earthquakes;


    }

    @RemoteAction
    public Static List<Earthquakes> findTopQuakes(){

        string dateString;
        Date todaysDate = system.today();

        dateString = String.valueOf(todaysDate.year()) + '-' + String.valueOf(todaysDate.month()) + '-' + String.valueOf(todaysDate.day());
        
        HttpRequest myRequest = new HttpRequest();
        string url;

        //per googlemaps APIi -85 to 85 and -180 to 180 are the max bounds for the earth
        //the max rows we can get on the call is 500
        //Added a min Magnitude of 7 to try to reduce the size of the result set.  Throguh trial and error 7 returns around 100 earthquakes
        url = 'http://api.geonames.org/earthquakesJSON?north=85&south=-85&east=180&west=-180';
        url += '&username=cduncombe44';

        url += '&date=' + dateString;
        url += '&maxRows=500';

        myRequest.setEndpoint(url);
        myRequest.setMethod('GET');
        Http h = new Http();
        HttpResponse myResponse = h.send(myRequest);
        string resultFromCall = myResponse.getBody().replace('datetime','eqdatetime');
    
        equContainer eqCont = (equContainer)JSON.deserialize(resultFromCall, equContainer.class);
        
        eqCont.earthquakes.sort();

        list<Earthquakes> topten = new Earthquakes[10];
        integer count = 0;
        integer letterCount = 0;
        list<string> letters = new list<string>{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'};
        for(Earthquakes e : eqCont.earthquakes){
            if(count == 10){
                break;
            }
            if(datetime.valueOf(e.eqdatetime) < system.now().addMonths(-12)){
                continue;
            }
            e.letter = letters[letterCount];
            e.formattedDate = datetime.valueOf(e.eqdatetime).format('M/d/yy');
            e.formattedTime = datetime.valueOf(e.eqdatetime).format('h:mm a');
            
            topten.add(count,e);
            count += 1;
            letterCount += 1;
        }
        return topten;
    }

    public class equContainer{
         public List<Earthquakes> earthquakes  {get;set;}
    }

    public class Earthquakes implements Comparable {
        public String eqid          {get;set;}
        public Double magnitude     {get;set;}
        public Double lng           {get;set;}
        public String src           {get;set;}
        public Double depth         {get;set;}
        public String eqdatetime    {get;set;}
        public String formattedDate {get;set;}
        public String formattedTime {get;set;}
        public Double lat           {get;set;}
        public String letter        {get;set;}


        public Integer compareTo(Object compareTo) {
            Earthquakes compareToEQ = (Earthquakes)compareTo;
            if (magnitude == compareToEQ.magnitude){
                return 0;
            } 
            if (magnitude > compareToEQ.magnitude){
                return -1;
            }
            return 1;  
        }
    }
	
}