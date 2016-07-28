# coding: utf-8

import sys
reload(sys)
sys.setdefaultencoding('utf-8')

from contextlib import contextmanager
from functools import wraps
import hashlib
import json
import logging
import requests
from requests.exceptions import ConnectionError, ReadTimeout, SSLError
import urllib

from config import UCLOUD_PUBLICKEY, UCLOUD_PRIVATEKEY


UCLOUD_API = 'https://api.ucloud.cn/'
REGIONS = [
    'cn-north-02',
    'cn-north-03',
    'cn-north-04',
    'cn-south-02',
    'hk-01',
    'us-west-01',
]
LIMIT = 1000


LOG_FORMAT = '[%(asctime)s] [%(process)s] [%(levelname)s] [%(name)s] %(message)s'
DATE_FORMAT = '%Y-%m-%d %H:%M:%S %z'
logging.basicConfig(level=logging.INFO, format=LOG_FORMAT, datefmt=DATE_FORMAT)
_log = logging.getLogger(__name__)


class UCloudAPI(object):
    """UCloud API with authentication."""

    def __init__(self, private_key=UCLOUD_PRIVATEKEY, public_key=UCLOUD_PUBLICKEY):
        self.prikey = private_key
        self.pubkey = public_key
        self.params = {'PublicKey': self.pubkey, 'Action': None}
        self.session = requests.Session()

    def update_params(self, params):
        self.params.update(params)
        self.params['Signature'] = self._verfy_ac(self.params)

    @property
    def url(self):
        return '?'.join([UCLOUD_API, urllib.urlencode(self.params)])

    def get(self):
        try:
            r = self.session.get(self.url)
            rjson = json.loads(r.text)
            if r.status_code == 200 and rjson['RetCode'] == 0:
                return rjson
        except ConnectionError as e:
            _log.error('ConnectionError: %s for request <GET %s>', e, self.url)
        except ReadTimeout as e:
            _log.error('ReadTimeout: %s for request <GET %s>', e, self.url)
        except SSLError as e:
            _log.error('SSLError: %s for request <GET %s>', e, self.url)
        except:
            _log.error('Error response for request <GET %s>', self.url)
        return {}

    def _verfy_ac(self, params):
        """Generate signature."""

        items = sorted(params.items())
        params_data = ''
        for key, value in items:
            params_data += str(key) + str(value)
        params_data += self.prikey
        
        sign = hashlib.sha1()
        sign.update(params_data)
        signature = sign.hexdigest()
        return signature


def with_action(action):
    if not isinstance(action, str):
        raise TypeError
    def deco(func):
        @wraps(func)
        def _(self, *args, **kwargs):
            self.params.update({'Action': action})
            try:
                return func(self, *args, **kwargs)
            except ValueError:
                pass
        return _
    return deco


@contextmanager
def reset_params(self):
    try:
        yield
    finally:
        self.params = {'PublicKey': self.pubkey, 'Action': None}


class NodeAPI(UCloudAPI):
    """Ucloud API for node operations."""

    def __init__(self):
        super(NodeAPI, self).__init__()

    def _get_diskspace(self, diskset):
        space = 0
        for disk in iter(diskset):
            space += disk['Size'] if disk['Type'] == 'Data' else 0
        return space

    @with_action('DescribeUHostInstance')
    def get_nodes(self, region):
        """DescribeUHostInstance.
        :param region: region

        :return: [u'Action', u'TotalCount', u'RetCode', u'UHostSet']
        """
        with reset_params(self):
            self.update_params({'Region': region, 'Limit': LIMIT})
            return self.get()

    @with_action('DescribeUHostInstance')
    def get_node(self, region, uuid=None):
        """DescribeUHostInstance. Get single node.
        :param region: region
        :param uuid: uuid

        :return: [u'Action', u'TotalCount', u'RetCode', u'UHostSet']
        """
        with reset_params(self):
            self.update_params({'Region': region, 'UHostIds.0': uuid})
            return self.get()

    @with_action('GetUHostInstancePrice')
    def get_price(self, node):
        """GetUHostInstancePrice.
        :param node: node, node must be a dict
        """
        with reset_params(self):
            self.update_params({
                'Region': node['Region'],
                'ImageId': node['ImageId'],
                'CPU': node['CPU'],
                'Memory': node['Memory'],
                'ChargeType': node['ChargeType'],
                'DiskSpace': node['DiskSpace'],
                'UHostType': node['UHostType'],
                'NetCapability': node['NetCapability'],
                'Count': 1,
            })
            return self.get()

    @with_action('DescribeImage')
    def get_baseimageid(self, image_id):
        """DescribeImage.
        """
        pass



def get_node_price(region='cn-north-03', uhostid='uhost-wtw1sj'):
    nodeapi = NodeAPI()
    x = nodeapi.get_node(region, uhostid)['UHostSet'][0]
    diskspace = nodeapi._get_diskspace(x['DiskSet'])
    if not x.get('BasicImageId', None):
        try:
            image_id = x['ImageId']
        except ValueError:
            _log.error("Failed to find base_image_id for node: <%s> in region", x, region)
            return
        x['BasicImageId'] = nodeapi.get_baseimageid(image_id)
    node = {
        'UHostId': x['UHostId'],
        'Name': x['Name'],
        'ImageId': x.['BasicImageId'],
        'CPU': x['CPU'],
        'Memory': x['Memory'],
        'ChargeType': x['ChargeType'],
        'UHostType': x['UHostType'],
        'NetCapability': x['NetCapability'],
        'Region': region,
        'DiskSpace': diskspace,
    }
    price = nodeapi.get_price(node)
    price = price['PriceSet'][0]['Price']


def get_nodes_by_region(region='cn-north-03'):
    nodeapi = NodeAPI()

    # Get all nodes in region
    _log.info('Fetching result for region: <%s>', region)
    nodes = nodeapi.get_nodes(region)
    if not nodes:
        _log.info('No node for region: <%s>', region)        
        return
    _log.info('There are %s nodes in region: <%s>', nodes['TotalCount'], region)

    # Add price into nodes list
    # TODO(ayakashi): multi threading there
    for x in iter(nodes['UHostSet']):
        if not x.get('BasicImageId', None):
            try:
                image_id = x['ImageId']
            except ValueError:
                _log.error("Failed to find base_image_id for node: <%s> in region", x, region)
                continue
            x['BasicImageId'] = nodeapi.get_baseimageid(image_id)

        try:
            diskspace = nodeapi._get_diskspace(x['DiskSet'])
            node = {
                'UHostId': x['UHostId'],
                'Name': x['Name'],
                'ImageId': x['BasicImageId'],
                'CPU': x['CPU'],
                'Memory': x['Memory'],
                'ChargeType': x['ChargeType'],
                'UHostType': x['UHostType'],
                'NetCapability': x['NetCapability'],
                'Region': region,
                'DiskSpace': diskspace,
            }
        except KeyError:
            _log.error("Error happens when fetching node: <%s>'s price in region: <%s>", x, region)
            continue
        _log.info('Fetching price for node: <%s> in region: <%s>', x['UHostId'], region)
        price = nodeapi.get_price(node)
        if not price:
            price = 0
        else:
            try:
                price = price['PriceSet'][0]['Price']
            except:
               import pdb; pdb.set_trace() 
        x['Price'] = price

        # 'Remark': 'tech-ops-pyang-zpang-0'
        remark = x['Remark']
        if not remark:
            deparment = group = leader = person = orderno = x['Tag']
        else:
            try:
                department, group, leader, person, orderno = x['Remark'].split('-')
            except ValueError:
                _log.error("Error remark format: <%s> for node: <%s> in region: <%s>", remark, node, region)
                continue
        print x


if __name__ == '__main__':
    print get_node_price()
#    print NodeAPI().get_node('cn-north-03', 'uhost-q11sg3')['UHostSet']
#    for region in REGIONS:
#        get_nodes_by_region(region)
