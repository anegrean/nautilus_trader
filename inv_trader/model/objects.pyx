#!/usr/bin/env python3
# -------------------------------------------------------------------------------------------------
# <copyright file="objects.pyx" company="Invariance Pte">
#  Copyright (C) 2018-2019 Invariance Pte. All rights reserved.
#  The use of this source code is governed by the license as found in the LICENSE.md file.
#  http://www.invariance.com
# </copyright>
# -------------------------------------------------------------------------------------------------

# cython: language_level=3, boundscheck=False, wraparound=False, nonecheck=False

from cpython.datetime cimport datetime

from inv_trader.core.precondition cimport Precondition
from inv_trader.enums.venue cimport Venue, venue_string
from inv_trader.enums.resolution cimport Resolution, resolution_string
from inv_trader.enums.quote_type cimport QuoteType, quote_type_string
from inv_trader.enums.security_type cimport SecurityType
from inv_trader.enums.currency_code cimport CurrencyCode


cdef class Symbol:
    """
    Represents the symbol for a financial market tradeable instrument.
    """

    def __init__(self,
                 str code,
                 Venue venue):
        """
        Initializes a new instance of the Symbol class.

        :param code: The symbols code.
        :param venue: The symbols venue.
        :raises ValueError: If the code is not a valid string.
        """
        Precondition.valid_string(code, 'code')

        self.code = code.upper()
        self.venue = venue

    cdef str venue_string(self):
        """
        :return: The venue string. 
        """
        return venue_string(self.venue)

    cdef bint equals(self, Symbol other):
        """
        Compare if the object equals the given object.
        
        :param other: The other object to compare
        :return: True if the objects are equal, otherwise False.
        """
        return self.code == other.code and self.venue == other.venue

    def __eq__(self, Symbol other) -> bool:
        """
        Override the default equality comparison.
        """
        return self.equals(other)

    def __ne__(self, Symbol other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.equals(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash((self.code, self.venue))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the symbol.
        """
        return str(f"{self.code}.{venue_string(self.venue)}")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the symbol.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class Tick:
    """
    Represents a single tick in a financial market.
    """

    def __init__(self,
                 Symbol symbol,
                 object bid,
                 object ask,
                 datetime timestamp):
        """
        Initializes a new instance of the Tick class.

        :param symbol: The tick symbol.
        :param bid: The tick best bid price.
        :param ask: The tick best ask price.
        :param timestamp: The tick timestamp (UTC).
        :raises ValueError: If the bid is not positive (> 0).
        :raises ValueError: If the ask is not positive (> 0).
        """
        Precondition.positive(bid, 'bid')
        Precondition.positive(ask, 'ask')

        self.symbol = symbol
        self.bid = bid
        self.ask = ask
        self.timestamp = timestamp

    def __eq__(self, Tick other) -> bool:
        """
        Override the default equality comparison.
        """
        return (self.symbol == other.symbol
                    and self.bid == other.bid
                    and self.ask == other.ask
                    and self.timestamp == other.timestamp)

    def __ne__(self, Tick other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(self.timestamp)

    def __str__(self) -> str:
        """
        :return: The str() string representation of the tick.
        """
        return str(f"Tick({self.symbol},{self.bid},{self.ask},"
                f"{self.timestamp.isoformat()})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the tick.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class BarType:
    """
    Represents a financial market symbol and bar specification.
    """

    def __init__(self,
                 Symbol symbol,
                 int period,
                 Resolution resolution,
                 QuoteType quote_type):
        """
        Initializes a new instance of the BarType class.

        :param symbol: The bar symbol.
        :param period: The bar period.
        :param resolution: The bar resolution.
        :param quote_type: The bar quote type.
        :raises ValueError: If the period is not positive (> 0).
        """
        Precondition.positive(period, 'period')

        self.symbol = symbol
        self.period = period
        self.resolution = resolution
        self.quote_type = quote_type

    cdef str resolution_string(self):
        """
        :return: The resolution string. 
        """
        return resolution_string(self.resolution)

    cdef str quote_type_string(self):
        """
        :return: The quote type string. 
        """
        return quote_type_string(self.quote_type)

    cdef bint equals(self, BarType other):
        """
        Compare if the object equals the given object.
        
        :param other: The other object to compare
        :return: True if the objects are equal, otherwise False.
        """
        return (self.symbol == other.symbol
                and self.period == other.period
                and self.resolution == other.resolution
                and self.quote_type == other.quote_type)

    def __eq__(self, BarType other) -> bool:
        """
        Override the default equality comparison.
        """
        return self.equals(other)

    def __ne__(self, BarType other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.equals(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash((self.symbol, self.period, self.resolution, self.quote_type))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the bar type.
        """
        return str(f"{str(self.symbol)}"
                f"-{self.period}-{resolution_string(self.resolution)}[{quote_type_string(self.quote_type)}]")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the bar type.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class Bar:
    """
    Represents a financial market trade bar.
    """

    def __init__(self,
                 object open_price,
                 object high_price,
                 object low_price,
                 object close_price,
                 long volume,
                 datetime timestamp,
                 bint checked=False):
        """
        Initializes a new instance of the Bar class.

        :param open_price: The bars open price.
        :param high_price: The bars high price.
        :param low_price: The bars low price.
        :param close_price: The bars close price.
        :param volume: The bars volume.
        :param timestamp: The bars timestamp (UTC).
        :param checked: A value indicating whether the bar was checked valid.
        :raises ValueError: If the open_price is not positive (> 0).
        :raises ValueError: If the high_price is not positive (> 0).
        :raises ValueError: If the low_price is not positive (> 0).
        :raises ValueError: If the close_price is not positive (> 0).
        :raises ValueError: If the volume is negative.
        :raises ValueError: If the high_price is not >= low_price.
        :raises ValueError: If the high_price is not >= close_price.
        :raises ValueError: If the low_price is not <= close_price.
        """
        if checked:
            Precondition.positive(open_price, 'open_price')
            Precondition.positive(high_price, 'high_price')
            Precondition.positive(low_price, 'low_price')
            Precondition.positive(close_price, 'close_price')
            Precondition.not_negative(volume, 'volume')
            Precondition.true(high_price >= low_price, 'high_price >= low_price')
            Precondition.true(high_price >= close_price, 'high_price >= close_price')
            Precondition.true(low_price <= close_price, 'low_price <= close_price')

        self.open = open_price
        self.high = high_price
        self.low = low_price
        self.close = close_price
        self.volume = volume
        self.timestamp = timestamp
        self.checked = checked

    def __eq__(self, Bar other) -> bool:
        """
        Override the default equality comparison.
        """
        return self.timestamp == other.timestamp

    def __ne__(self, Bar other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(str(self.timestamp))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the bar.
        """
        return str(f"Bar({self.open},{self.high},{self.low},{self.close},"
                f"{self.volume},{self.timestamp.isoformat()})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the bar.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class DataBar:
    """
    Represents a financial market trade bar.
    """

    def __init__(self,
                 float open_price,
                 float high_price,
                 float low_price,
                 float close_price,
                 float volume,
                 datetime timestamp):
        """
        Initializes a new instance of the DataBar class.

        :param open_price: The bars open price.
        :param high_price: The bars high price.
        :param low_price: The bars low price.
        :param close_price: The bars close price.
        :param volume: The bars volume.
        :param timestamp: The bars timestamp (UTC).
        :raises ValueError: If the open_price is not positive (> 0).
        :raises ValueError: If the high_price is not positive (> 0).
        :raises ValueError: If the low_price is not positive (> 0).
        :raises ValueError: If the close_price is not positive (> 0).
        :raises ValueError: If the volume is negative.
        """
        self.open = open_price
        self.high = high_price
        self.low = low_price
        self.close = close_price
        self.volume = volume
        self.timestamp = timestamp

    def __eq__(self, DataBar other) -> bool:
        """
        Override the default equality comparison.
        """
        return self.open == other.open

    def __ne__(self, DataBar other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(str(self.timestamp))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the bar.
        """
        return str(f"DataBar({self.open},{self.high},{self.low},{self.close},"
                f"{self.volume},{self.timestamp.isoformat()})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the bar.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class Instrument:
    """
    Represents a tradeable financial market instrument.
    """

    def __init__(self,
                 Symbol symbol,
                 str broker_symbol,
                 CurrencyCode quote_currency,
                 SecurityType security_type,
                 int tick_precision,
                 object tick_size,
                 object tick_value,
                 object target_direct_spread,
                 int round_lot_size,
                 int contract_size,
                 int min_stop_distance_entry,
                 int min_limit_distance_entry,
                 int min_stop_distance,
                 int min_limit_distance,
                 int min_trade_size,
                 int max_trade_size,
                 object margin_requirement,
                 object rollover_interest_buy,
                 object rollover_interest_sell,
                 datetime timestamp):
        """
        Initializes a new instance of the Instrument class.

        :param symbol: The instruments symbol.
        :param broker_symbol: The instruments broker symbol.
        :param quote_currency: The instruments quote currency.
        :param security_type: The instruments security type.
        :param tick_precision: The instruments tick decimal digits precision.
        :param tick_size: The instruments tick size.
        :param tick_value: The instruments tick value.
        :param target_direct_spread: The instruments target direct spread (set by broker).
        :param round_lot_size: The instruments rounded lot size.
        :param contract_size: The instruments contract size if applicable.
        :param min_stop_distance_entry: The instruments minimum distance for stop entry orders.
        :param min_limit_distance_entry: The instruments minimum distance for limit entry orders.
        :param min_stop_distance: The instruments minimum tick distance for stop orders.
        :param min_limit_distance: The instruments minimum tick distance for limit orders.
        :param min_trade_size: The instruments minimum trade size.
        :param max_trade_size: The instruments maximum trade size.
        :param margin_requirement: The instruments margin requirement per unit.
        :param rollover_interest_buy: The instruments rollover interest for long positions.
        :param rollover_interest_sell: The instruments rollover interest for short positions.
        :param timestamp: The timestamp the instrument was created/updated at.
        """
        Precondition.valid_string(broker_symbol, 'broker_symbol')
        Precondition.not_negative(tick_precision, 'tick_precision')
        Precondition.positive(tick_size, 'tick_size')
        Precondition.positive(tick_value, 'tick_value')
        Precondition.not_negative(target_direct_spread, 'target_direct_spread')
        Precondition.positive(contract_size, 'contract_size')
        Precondition.not_negative(min_stop_distance_entry, 'min_stop_distance_entry')
        Precondition.not_negative(min_limit_distance_entry, 'min_limit_distance_entry')
        Precondition.not_negative(min_stop_distance, 'min_stop_distance')
        Precondition.not_negative(min_limit_distance, 'min_limit_distance')
        Precondition.not_negative(min_limit_distance, 'min_limit_distance')
        Precondition.positive(min_trade_size, 'min_trade_size')
        Precondition.positive(max_trade_size, 'max_trade_size')
        Precondition.not_negative(margin_requirement, 'margin_requirement')

        self.symbol = symbol
        self.broker_symbol = broker_symbol
        self.quote_currency = quote_currency
        self.security_type = security_type
        self.tick_precision = tick_precision
        self.tick_size = tick_size
        self.tick_value = tick_value
        self.target_direct_spread = target_direct_spread
        self.round_lot_size = round_lot_size
        self.contract_size = contract_size
        self.min_stop_distance_entry = min_stop_distance_entry
        self.min_limit_distance_entry = min_limit_distance_entry
        self.min_stop_distance = min_stop_distance
        self.min_limit_distance = min_limit_distance
        self.min_trade_size = min_trade_size
        self.max_trade_size = max_trade_size
        self.margin_requirement = margin_requirement
        self.rollover_interest_buy = rollover_interest_buy
        self.rollover_interest_sell = rollover_interest_sell
        self.timestamp = timestamp

    def __eq__(self, Instrument other) -> bool:
        """
        Override the default equality comparison.
        """
        return self.symbol == other.symbol

    def __ne__(self, Instrument other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(str(self.symbol))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the instrument.
        """
        return str(f"Instrument({self.symbol})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the instrument.
        """
        return str(f"<{str(self)} object at {id(self)}>")
