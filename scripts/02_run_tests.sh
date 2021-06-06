#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -xe
: ${KUBECONFIG:="$HOME/.kube/config"}
# Available Modes: quick, certified-conformance, non-disruptive-conformance.
# (default quick)
: ${CONFORMANCE_MODE:="quick"}
#: ${KUBE_CONFORMANCE_IMAGE_VERSION:="v1.18.6"}
: ${TIMEOUT:=10800}
#: ${TARGET_CLUSTER_CONTEXT:="target-cluster"}
: ${E2E_SKIP:=""}

mkdir -p /tmp/sonobuoy_snapshots/e2e
cd /tmp/sonobuoy_snapshots/e2e

sonobuoy run --plugin e2e --plugin systemd-logs -m ${CONFORMANCE_MODE} --e2e-skip "${E2E_SKIP}" \
	--kubeconfig ${KUBECONFIG} \
	--wait --timeout ${TIMEOUT} \
	--log_dir /tmp/sonobuoy_snapshots/e2e

# Get information on pods
kubectl get all -n sonobuoy --kubeconfig ${KUBECONFIG}

# Check sonobuoy status
sonobuoy status --kubeconfig ${KUBECONFIG}

# Get logs
sonobuoy logs --kubeconfig ${KUBECONFIG}

# Store Results
results=$(sonobuoy retrieve --kubeconfig ${KUBECONFIG})
echo "Results: ${results}"

# Display Results
sonobuoy results $results
ls -ltr /tmp/sonobuoy_snapshots/e2e

# Delete sonobuoy objects
echo "Deleting sonobuoy objects"
sonobuoy delete --wait --kubeconfig ${KUBECONFIG}
