(:  Dado el código identificador del país devuelve un elemento <country> con el nombre del país asociado
    a dicho código :)
declare function local:getCountry($country as element()) as element(country) {
    let $country := doc("./countries.xml")//response[./code/text() = $country/text()]/name/text()
    return <country>{$country}</country>
};

(:  Dado el iata_code del aeropuerto y un string, crea un elemento cuyo nombre es el string recibido y 
    contiene como subelementos el nombre del aeropuerto asociado a dicho iata_code y el país donde se ubica
    El tipo de retorno es node()?, el cual significa que la función devuelve un nodo OPCIONAL
    Si el nombre del aeropuerto o el país del mismo no existen, devuelve null (secuencia vacia) :)
declare function local:getAirport($code as xs:string, $type as xs:string) as node()? {
    (: Con el [1], se queda únicamente con la primera referencia que valide dicho código :)
    let $airport := (doc("./airports.xml")//response[./iata_code/text() = $code])[1]
    (:  element es el constructor de un elemento en XQuery
        Su sintaxis es element {nombre del elemento} {subelementos y atributos separados por comas} :)
    return if(exists($airport/name) and exists($airport/country_code)) then element {$type} {
        local:getCountry($airport/country_code),
        $airport/name
    } else ()
};

(:  Se encarga de devolver todos los vuelos con su respectiva informacion: id como atributo (obligatorio), 
    pais, latitud y longitud, status (obligatorio) y la informacion del aeropuerto de salida y llegada :)
declare function local:getFlights() as node()* {
    (: Se queda únicamente con los vuelos que contengan un id (hex) y luego los ordena ascendentemente :)
    for $flight in doc("./flights.xml")//response[./hex]
    order by $flight/hex/text() ascending
    return <flight id="{$flight/hex}">
        {if (exists($flight/flag)) then local:getCountry($flight/flag) else ()}
        <position>
            {$flight/lat}
            {$flight/lng}
        </position>
        {$flight/status}
        {if (exists($flight/dep_iata)) 
            then 
                local:getAirport($flight/dep_iata/text(), 'departure_airport')
            else ()
        }
        {if (exists($flight/arr_iata)) 
            then 
                local:getAirport($flight/arr_iata/text(), 'arrival_airport')
            else ()
        }
    </flight>
};

(: Devuelve true si aparece al menos un error en alguno de los tres documentos XML :)
declare function local:checkForErrors() as xs:boolean {
    exists(doc("./airports.xml")//error) or exists(doc("./countries.xml")//error) or exists(doc("./flights.xml")//error)
};

(: Devuelve nodos <error> de todos los errores que se encuentren en los tres documentos XML :)
declare function local:returnErrors() as node()* {
    let $airportError := doc("./airports.xml")//error/message/text()
    let $countryError := doc("./countries.xml")//error/message/text()
    let $flightError := doc("./flights.xml")//error/message/text()
    let $errors := ($airportError, $countryError, $flightError)
    for $error in $errors
    return <error>{$error}</error>
}; 

(:  En flights_data iran los elementos <error> si es que existe el menos uno de ellos en los documentos
    airports.xml, flights.xml o countries.xml
    Si no hay errores entonces devuelve todos los vuelos en flights.xml ordenadas ascendentemente por su id :)
<flights_data>{
    if (local:checkForErrors())
    then
        local:returnErrors()
    else
        local:getFlights()
}
</flights_data>