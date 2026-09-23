import logging
import pandas as pd

from typing import List, Dict, Any

from dataclasses import dataclass, field

import boto3
from botocore.exceptions import ClientError
import awswrangler as wr

logger = logging.getLogger()
logger.setLevel(logging.INFO)

BUCKET_NAME = "financial-dataflow"
# PREFIX = "data/bronze/trading212/positions/2026/09/14/"
PREFIX = "data/silver/trading212/positions/ingested_date=2026-09-14/"
REGION_NAME = "eu-west-1"


@dataclass
class Asset:
  name: str
  ticker: str
  current_value: float
  total_cost: float

try:
  s3_client = boto3.client("s3", REGION_NAME)
except ClientError as e:
  logger.error(e)


def holdings()-> List[Dict[str, Any]]:
  try:
    res = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=PREFIX)
    objects = [{"key": r["Key"], "LastModified": r["LastModified"]} for r in res.get("Contents")]
    return objects
  except ClientError as e:
    logger.error(e)
    return []
  

def get_current_holdings(holdings: List[Dict[str, Any]] = None, sort_by: str = "LastModified") -> Dict[str, Any]:
    holdings = holdings.copy()
    holdings.sort(key=lambda x: x[sort_by], reverse=True)
    return holdings[0]

def main():
    current_holdings = get_current_holdings(holdings=holdings(), sort_by="LastModified")
    
    path = f"s3://{BUCKET_NAME}/{current_holdings['key']}"
  
    print(f"Loading current holdings from: {path}")
    current_holdings = wr.s3.read_parquet(
        path,
    )
    
    cols = ["name", "ticker", "current_value", "total_cost"]
    
    current_holdings = current_holdings[cols]
    current_holdings = current_holdings[~current_holdings.duplicated(subset=["ticker"], keep="last")]
    current_holdings = current_holdings.sort_values("current_value", ascending=False)
    
    current_account_value = current_holdings["current_value"].sum()
    
    current_holdings["pct_weight"] = current_holdings["current_value"] / current_account_value * 100
    
    print(f"Current account value: {current_account_value}")
    print(f"Total Assets: {len(current_holdings)}")
    # print(current_holdings.head(10))
    
    current_holdings.to_csv("current_holdings.csv", index=False)

if __name__ == "__main__":
    main()