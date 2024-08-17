# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2024 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from functools import lru_cache
import datetime as dt

from nautilus_trader.adapters.databento.enums import DatabentoSchema
from nautilus_trader.core.correctness import PyCondition
from nautilus_trader.model.data import BarType
from nautilus_trader.model.enums import BarAggregation
from nautilus_trader.model.enums import PriceType
from nautilus_trader.model.identifiers import InstrumentId


def databento_schema_from_nautilus_bar_type(bar_type: BarType) -> DatabentoSchema:
    """
    Return the Databento bar aggregate schema string for the given Nautilus `bar_type`.

    Parameters
    ----------
    bar_type : BarType
        The bar type for the schema.

    Returns
    -------
    str

    Raises
    ------
    ValueError
        If any property of `bar_type` is invalid to map to a Databento schema.

    """
    PyCondition.true(bar_type.is_externally_aggregated(), "aggregation_source is not EXTERNAL")

    if not bar_type.spec.is_time_aggregated():
        raise ValueError(
            f"Invalid bar type '{bar_type}' (only time bars are aggregated by Databento).",
        )

    if bar_type.spec.price_type != PriceType.LAST:
        raise ValueError(
            f"Invalid bar type '{bar_type}' (only `LAST` price bars are aggregated by Databento).",
        )

    if bar_type.spec.step != 1:
        raise ValueError(
            f"Invalid bar type '{bar_type}' (only a step of 1 is supported by Databento).",
        )

    match bar_type.spec.aggregation:
        case BarAggregation.SECOND:
            return DatabentoSchema.OHLCV_1S
        case BarAggregation.MINUTE:
            return DatabentoSchema.OHLCV_1M
        case BarAggregation.HOUR:
            return DatabentoSchema.OHLCV_1H
        case BarAggregation.DAY:
            return DatabentoSchema.OHLCV_1D
        case _:
            raise ValueError(
                f"Invalid bar type '{bar_type}'. "
                "Use any of ['SECOND', 'MINTUE', 'HOUR', 'DAY'] time aggregations.",
            )
        
@lru_cache(20)
def map_instrumentId(instrument_id: InstrumentId) -> InstrumentId:
    """
    Map between Databento GLBX and Interactive Brokers CME instrument IDs.
    """
    # transform venue
    if instrument_id.venue.value == "GLBX":
        new_venue = "CME"
    elif instrument_id.venue.value == "CME":
        new_venue = "GLBX"
    else:
        new_venue = instrument_id.venue.value
    
    # transform symbol
    if instrument_id.symbol.value[-2].isdigit():
        new_symbol = instrument_id.symbol.value[:-2] + instrument_id.symbol.value[-1]
    elif instrument_id.symbol.value[-1].isdigit():
        # assume first digit of current year
        new_symbol = instrument_id.symbol.value[:-1] + str(dt.datetime.now().year)[0] + instrument_id.symbol.value[-1]
    else:
        new_symbol = instrument_id.symbol.value
    
    return InstrumentId.from_str(f"{new_symbol}.{new_venue}")
