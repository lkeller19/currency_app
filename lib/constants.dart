const List<String> popularCurrencies = ['JPY', 'GBP', 'EUR', 'AUD', 'CHF'];

const Map<String, int> mapSectionToKey = {
  '*': 0, 
  'A': 1,
  'B': 2,
  'C': 3,
  'D': 4,
  'E': 5,
  'F': 6,
  'G': 7,
  'H': 8,
  'I': 9,
  'J': 10,
  'K': 11,
  'L': 12,
  'M': 13,
  'N': 14,
  'O': 15,
  'P': 16,
  'Q': 17,
  'R': 18,
  'S': 19,
  'T': 20,
  'U': 21,
  'V': 22,
  'W': 23,
  'X': 24,
  'Y': 25,
  'Z': 26,
};

const Map<String, dynamic> worldCurrencies = {
  'AED': {"name": "United Arab Emirates Dirham", "symbol": "د.إ"},
  'AFN': {"name": "Afghan Afghani", "symbol": "؋"},
  'ALL': {"name": "Albanian Lek", "symbol": "L"},
  'AMD': {"name": "Armenian Dram", "symbol": "֏"},
  'ANG': {"name": "Netherlands Antillean Guilder", "symbol": "ƒ"},
  'AOA': {"name": "Angolan Kwanza", "symbol": "Kz"},
  'ARS': {"name": "Argentine Peso", "symbol": "\$"},
  'AUD': {"name": "Australian Dollar", "symbol": "\$"},
  'AWG': {"name": "Aruban Florin", "symbol": "ƒ"},
  'AZN': {"name": "Azerbaijani Manat", "symbol": "₼"},
  'BAM': {"name": "Bosnia and Herzegovina Convertible Mark", "symbol": "KM"},
  'BBD': {"name": "Barbadian or Bajan Dollar", "symbol": "\$"},
  'BDT': {"name": "Bangladeshi Taka", "symbol": "৳"},
  'BGN': {"name": "Bulgarian Lev", "symbol": "лв"},
  'BHD': {"name": "Bahraini Dinar", "symbol": "ب.د"},
  'BIF': {"name": "Burundian Franc", "symbol": "Fr"},
  'BMD': {"name": "Bermudian Dollar", "symbol": "\$"},
  'BND': {"name": "Bruneian Dollar", "symbol": "\$"},
  'BOB': {"name": "Bolivian Bolíviano", "symbol": "Bs."},
  'BRL': {"name": "Brazilian Real", "symbol": "R\$"},
  'BSD': {"name": "Bahamian Dollar", "symbol": "\$"},
  'BTC': {"name": "Bitcoin", "symbol": "₿"},
  'BTN': {"name": "Bhutanese Ngultrum", "symbol": "Nu."},
  'BWP': {"name": "Botswana Pula", "symbol": "P"},
  'BYN': {"name": "Belarusian Ruble", "symbol": "Br"},
  'BZD': {"name": "Belizean Dollar", "symbol": "BZ\$"},
  'CAD': {"name": "Canadian Dollar", "symbol": "\$"},
  'CDF': {"name": "Congolese Franc", "symbol": "Fr"},
  'CHF': {"name": "Swiss Franc", "symbol": "Fr"},
  'CLF': {"name": "Chilean Unidad de Fomento", "symbol": "UF"},
  'CLP': {"name": "Chilean Peso", "symbol": "\$"},
  'CNH': {"name": "Chinese Yuan Renminbi Offshore", "symbol": "¥"},
  'CNY': {"name": "Chinese Yuan Renminbi", "symbol": "¥"},
  'COP': {"name": "Colombian Peso", "symbol": "\$"},
  'CRC': {"name": "Costa Rican Colon", "symbol": "₡"},
  'CUC': {"name": "Cuban Convertible Peso", "symbol": "\$"},
  'CUP': {"name": "Cuban Peso", "symbol": "₱"},
  'CVE': {"name": "Cape Verdean Escudo", "symbol": "\$"},
  'CZK': {"name": "Czech Koruna", "symbol": "Kč"},
  'DJF': {"name": "Djiboutian Franc", "symbol": "Fdj"},
  'DKK': {"name": "Danish Krone", "symbol": "kr"},
  'DOP': {"name": "Dominican Peso", "symbol": "RD\$"},
  'DZD': {"name": "Algerian Dinar", "symbol": "د.ج"},
  'EGP': {"name": "Egyptian Pound", "symbol": "£"},
  'ERN': {"name": "Eritrean Nakfa", "symbol": "Nfk"},
  'ETB': {"name": "Ethiopian Birr", "symbol": "Br"},
  'EUR': {"name": "Euro", "symbol": "€"},
  'FJD': {"name": "Fijian Dollar", "symbol": "\$"},
  'FKP': {"name": "Falkland Island Pound", "symbol": "£"},
  'GBP': {"name": "British Pound", "symbol": "£"},
  'GEL': {"name": "Georgian Lari", "symbol": "₾"},
  'GGP': {"name": "Guernsey Pound", "symbol": "£"},
  'GHS': {"name": "Ghanaian Cedi", "symbol": "₵"},
  'GIP': {"name": "Gibraltar Pound", "symbol": "£"},
  'GMD': {"name": "Gambian Dalasi", "symbol": "D"},
  'GNF': {"name": "Guinean Franc", "symbol": "Fr"},
  'GTQ': {"name": "Guatemalan Quetzal", "symbol": "Q"},
  'GYD': {"name": "Guyanese Dollar", "symbol": "\$"},
  'HKD': {"name": "Hong Kong Dollar", "symbol": "\$"},
  'HNL': {"name": "Honduran Lempira", "symbol": "L"},
  'HRK': {"name": "Croatian Kuna", "symbol": "kn"},
  'HTG': {"name": "Haitian Gourde", "symbol": "G"},
  'HUF': {"name": "Hungarian Forint", "symbol": "Ft"},
  'IDR': {"name": "Indonesian Rupiah", "symbol": "Rp"},
  'ILS': {"name": "Israeli Shekel", "symbol": "₪"},
  'IMP': {"name": "Isle of Man Pound", "symbol": "£"},
  'INR': {"name": "Indian Rupee", "symbol": "₹"},
  'IQD': {"name": "Iraqi Dinar", "symbol": "ع.د"},
  'IRR': {"name": "Iranian Rial", "symbol": "﷼"},
  'ISK': {"name": "Icelandic Krona", "symbol": "kr"},
  'JEP': {"name": "Jersey Pound", "symbol": "£"},
  'JMD': {"name": "Jamaican Dollar", "symbol": "J\$"},
  'JOD': {"name": "Jordanian Dinar", "symbol": "د.ا"},
  'JPY': {"name": "Japanese Yen", "symbol": "¥"},
  'KES': {"name": "Kenyan Shilling", "symbol": "KSh"},
  'KGS': {"name": "Kyrgyzstani Som", "symbol": "с"},
  'KHR': {"name": "Cambodian Riel", "symbol": "៛"},
  'KMF': {"name": "Comorian Franc", "symbol": "Fr"},
  'KPW': {"name": "North Korean Won", "symbol": "₩"},
  'KRW': {"name": "South Korean Won", "symbol": "₩"},
  'KWD': {"name": "Kuwaiti Dinar", "symbol": "د.ك"},
  'KYD': {"name": "Caymanian Dollar", "symbol": "\$"},
  'KZT': {"name": "Kazakhstani Tenge", "symbol": "₸"},
  'LAK': {"name": "Lao or Laotian Kip", "symbol": "₭"},
  'LBP': {"name": "Lebanese Pound", "symbol": "£"},
  'LKR': {"name": "Sri Lankan Rupee", "symbol": "රු"},
  'LRD': {"name": "Liberian Dollar", "symbol": "\$"},
  'LSL': {"name": "Basotho Loti", "symbol": "L"},
  'LYD': {"name": "Libyan Dinar", "symbol": "ل.د"},
  'MAD': {"name": "Moroccan Dirham", "symbol": "د.م."},
  'MDL': {"name": "Moldovan Leu", "symbol": "L"},
  'MGA': {"name": "Malagasy Ariary", "symbol": "Ar"},
  'MKD': {"name": "Macedonian Denar", "symbol": "ден"},
  'MMK': {"name": "Burmese Kyat", "symbol": "K"},
  'MNT': {"name": "Mongolian Tughrik", "symbol": "₮"},
  'MOP': {"name": "Macau Pataca", "symbol": "P"},
  'MRU': {"name": "Mauritanian Ouguiya", "symbol": "UM"},
  'MUR': {"name": "Mauritian Rupee", "symbol": "₨"},
  'MVR': {"name": "Maldivian Rufiyaa", "symbol": "MVR"},
  'MWK': {"name": "Malawian Kwacha", "symbol": "MK"},
  'MXN': {"name": "Mexican Peso", "symbol": "\$"},
  'MYR': {"name": "Malaysian Ringgit", "symbol": "RM"},
  'MZN': {"name": "Mozambican Metical", "symbol": "MT"},
  'NAD': {"name": "Namibian Dollar", "symbol": "\$"},
  'NGN': {"name": "Nigerian Naira", "symbol": "₦"},
  'NIO': {"name": "Nicaraguan Cordoba", "symbol": "C\$"},
  'NOK': {"name": "Norwegian Krone", "symbol": "kr"},
  'NPR': {"name": "Nepalese Rupee", "symbol": "₨"},
  'NZD': {"name": "New Zealand Dollar", "symbol": "\$"},
  'OMR': {"name": "Omani Rial", "symbol": "ر.ع."},
  'PAB': {"name": "Panamanian Balboa", "symbol": "B/."},
  'PEN': {"name": "Peruvian Sol", "symbol": "S/."},
  'PGK': {"name": "Papua New Guinean Kina", "symbol": "K"},
  'PHP': {"name": "Philippine Peso", "symbol": "₱"},
  'PKR': {"name": "Pakistani Rupee", "symbol": "₨"},
  'PLN': {"name": "Polish Złoty", "symbol": "zł"},
  'PYG': {"name": "Paraguayan Guarani", "symbol": "₲"},
  'QAR': {"name": "Qatari Riyal", "symbol": "ر.ق"},
  'RON': {"name": "Romanian Leu", "symbol": "lei"},
  'RSD': {"name": "Serbian Dinar", "symbol": "дин"},
  'RUB': {"name": "Russian Ruble", "symbol": "₽"},
  'RWF': {"name": "Rwandan Franc", "symbol": "Fr"},
  'SAR': {"name": "Saudi Arabian Riyal", "symbol": "ر.س"},
  'SBD': {"name": "Solomon Islander Dollar", "symbol": "\$"},
  'SCR': {"name": "Seychellois Rupee", "symbol": "₨"},
  'SDG': {"name": "Sudanese Pound", "symbol": "£"},
  'SEK': {"name": "Swedish Krona", "symbol": "kr"},
  'SGD': {"name": "Singaporean Dollar", "symbol": "\$"},
  'SHP': {"name": "Saint Helenian Pound", "symbol": "£"},
  'SLL': {"name": "Sierra Leonean Leone", "symbol": "Le"},
  'SOS': {"name": "Somali Shilling", "symbol": "S"},
  'SRD': {"name": "Surinamese Dollar", "symbol": "\$"},
  'SSP': {"name": "South Sudanese Pound", "symbol": "£"},
  'STD': {"name": "Sao Tomean Dobra", "symbol": "Db"},
  'STN': {"name": "Sao Tomean Dobra", "symbol": "Db"},
  'SVC': {"name": "Salvadoran Colon", "symbol": "\$"},
  'SYP': {"name": "Syrian Pound", "symbol": "£"},
  'SZL': {"name": "Swazi Lilangeni", "symbol": "L"},
  'THB': {"name": "Thai Baht", "symbol": "฿"},
  'TJS': {"name": "Tajikistani Somoni", "symbol": "ЅМ"},
  'TMT': {"name": "Turkmenistani Manat", "symbol": "T"},
  'TND': {"name": "Tunisian Dinar", "symbol": "د.ت"},
  'TOP': {"name": "Tongan Pa'anga", "symbol": "T\$"},
  'TRY': {"name": "Turkish Lira", "symbol": "₺"},
  'TTD': {"name": "Trinidadian Dollar", "symbol": "TT\$"},
  'TWD': {"name": "Taiwan New Dollar", "symbol": "NT\$"},
  'TZS': {"name": "Tanzanian Shilling", "symbol": "TSh"},
  'UAH': {"name": "Ukrainian Hryvnia", "symbol": "₴"},
  'UGX': {"name": "Ugandan Shilling", "symbol": "USh"},
  'USD': {"name": "United States Dollar", "symbol": "\$"},
  'UYU': {"name": "Uruguayan Peso", "symbol": "\$U"},
  'UZS': {"name": "Uzbekistani Som", "symbol": "лв"},
  'VES': {"name": "Venezuelan Bolívar", "symbol": "Bs."},
  'VND': {"name": "Vietnamese Dong", "symbol": "₫"},
  'VUV': {"name": "Ni-Vanuatu Vatu", "symbol": "VT"},
  'WST': {"name": "Samoan Tala", "symbol": "T"},
  'XAF': {"name": "Central African CFA Franc BEAC", "symbol": "Fr"},
  'XAG': {"name": "Silver Ounce", "symbol": "XAG"},
  'XAU': {"name": "Gold Ounce", "symbol": "XAU"},
  'XCD': {"name": "East Caribbean Dollar", "symbol": "\$"},
  'XDR': {"name": "IMF Special Drawing Rights", "symbol": "SDR"},
  'XOF': {"name": "West African CFA Franc BCEAO", "symbol": "Fr"},
  'XPD': {"name": "Palladium Ounce", "symbol": "XPD"},
  'XPF': {"name": "CFP Franc", "symbol": "Fr"},
  'XPT': {"name": "Platinum Ounce", "symbol": "XPT"},
  'YER': {"name": "Yemeni Rial", "symbol": "﷼"},
  'ZAR': {"name": "South African Rand", "symbol": "R"},
  'ZMW': {"name": "Zambian Kwacha", "symbol": "ZK"},
  'ZWL': {"name": "Zimbabwean Dollar", "symbol": "Z\$"},
};
